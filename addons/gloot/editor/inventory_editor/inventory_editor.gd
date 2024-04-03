@tool
extends Control

const Undoables = preload("res://addons/gloot/editor/undoables.gd")
const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const PropertiesEditor = preload("res://addons/gloot/editor/item_editor/properties_editor.tscn")
const POPUP_SIZE = Vector2i(800, 300)

@onready var hsplit_container = $HSplitContainer
@onready var prototype_id_filter = $HSplitContainer/ChoiceFilter
@onready var inventory_control_container = $HSplitContainer/VBoxContainer
@onready var btn_edit = $HSplitContainer/VBoxContainer/HBoxContainer/BtnEdit
@onready var btn_remove = $HSplitContainer/VBoxContainer/HBoxContainer/BtnRemove
@onready var scroll_container = $HSplitContainer/VBoxContainer/ScrollContainer
var inventory: Inventory :
    set(new_inventory):
        disconnect_inventory_signals()
        inventory = new_inventory
        connect_inventory_signals()

        _refresh()
var _inventory_control: Control
var _inventory_container: Control
var _properties_editor: Window


func connect_inventory_signals():
    if !inventory:
        return

    if inventory is InventoryStacked:
        inventory.capacity_changed.connect(_refresh)
    if inventory is InventoryGrid:
        inventory.size_changed.connect(_refresh)
    inventory.protoset_changed.connect(_refresh)

    if !inventory.protoset:
        return
    inventory.protoset.changed.connect(_refresh)


func disconnect_inventory_signals():
    if !inventory:
        return
        
    if inventory is InventoryStacked:
        inventory.capacity_changed.disconnect(_refresh)
    if inventory is InventoryGrid:
        inventory.size_changed.disconnect(_refresh)
    inventory.protoset_changed.disconnect(_refresh)

    if !inventory.protoset:
        return
    inventory.protoset.changed.disconnect(_refresh)


func _refresh() -> void:
    if !is_inside_tree() || inventory == null || inventory.protoset == null:
        return
        
    # Remove the inventory control, if present
    if _inventory_container:
        scroll_container.remove_child(_inventory_container)
        _inventory_container.queue_free()
        _inventory_container = null

    # Create the appropriate inventory control and populate it
    _inventory_container = _create_inventory_container()
    scroll_container.add_child(_inventory_container)

    # Set prototype_id_filter values
    prototype_id_filter.set_values(inventory.protoset._prototypes.keys())


func _create_inventory_container() -> Control:
    var vbox_container: Control = VBoxContainer.new()
    vbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
    vbox_container.size_flags_vertical = SIZE_EXPAND_FILL
    var capacity_control: GlootInventoryCapacity = null

    if inventory.get_grid_constraint() != null:
        _inventory_control = GlootInventoryGrid.new()
        _inventory_control.field_style = preload("res://addons/gloot/ui/default_grid_field.tres")
        _inventory_control.selection_style = preload("res://addons/gloot/ui/default_grid_selection.tres")
    else:
        _inventory_control = GlootInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory
    _inventory_control.inventory_item_activated.connect(_on_inventory_item_activated)
    _inventory_control.inventory_item_context_activated.connect(_on_inventory_item_context_activated)

    if inventory.get_weight_constraint() != null:
        capacity_control = GlootInventoryCapacity.new()
        capacity_control.inventory = inventory

    if _inventory_control:
        vbox_container.add_child(_inventory_control)
    if capacity_control:
        vbox_container.add_child(capacity_control)

    return vbox_container


func _on_inventory_item_activated(item: InventoryItem) -> void:
    Undoables.exec_inventory_undoable([inventory], "Remove Inventory Item", func():
        return inventory.remove_item(item)
    )


func _on_inventory_item_context_activated(item: InventoryItem) -> void:
    Undoables.exec_inventory_undoable([inventory], "Rotate Inventory Item", func():
        var grid_constraint := inventory.get_grid_constraint()
        if grid_constraint == null:
            return false
        var rotated = grid_constraint.get_item_rotation(item)
        return grid_constraint.set_item_rotation(item, !rotated)
    )


func _ready() -> void:
    prototype_id_filter.pick_icon = EditorIcons.get_icon("Add")
    prototype_id_filter.filter_icon = EditorIcons.get_icon("Search")
    btn_edit.icon = EditorIcons.get_icon("Edit")
    btn_remove.icon = EditorIcons.get_icon("Remove")

    prototype_id_filter.choice_picked.connect(_on_prototype_id_picked)
    btn_edit.pressed.connect(_on_btn_edit)
    btn_remove.pressed.connect(_on_btn_remove)
    _refresh()


func _on_prototype_id_picked(index: int) -> void:
    var prototype_id = prototype_id_filter.values[index]
    Undoables.exec_inventory_undoable([inventory], "Add Inventory Item", func():
        return (inventory.create_and_add_item(prototype_id) != null)
    )
    

func _on_btn_edit() -> void:
    var selected_item: InventoryItem = _inventory_control.get_selected_inventory_item()
    if selected_item == null:
        return
    if _properties_editor == null:
        _properties_editor = PropertiesEditor.instantiate()
        add_child(_properties_editor)
    _properties_editor.item = selected_item
    _properties_editor.popup_centered(POPUP_SIZE)


func _on_btn_remove() -> void:
    var selected_items: Array[InventoryItem] = _inventory_control.get_selected_inventory_items()
    for selected_item in selected_items:
        if selected_item != null:
            Undoables.exec_inventory_undoable([inventory], "Remove Inventory Item", func():
                return inventory.remove_item(selected_item)
            )


static func _select_node(node: Node) -> void:
    EditorInterface.get_selection().clear()
    EditorInterface.get_selection().add_node(node)
    EditorInterface.edit_node(node)

