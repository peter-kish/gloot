@tool
extends Control

const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")

@onready var hsplit_container = $HSplitContainer
@onready var prototype_id_filter = $HSplitContainer/ChoiceFilter
@onready var inventory_control_container = $HSplitContainer/VBoxContainer
@onready var btn_edit = $HSplitContainer/VBoxContainer/HBoxContainer/BtnEdit
@onready var btn_remove = $HSplitContainer/VBoxContainer/HBoxContainer/BtnRemove
@onready var scroll_container = $HSplitContainer/VBoxContainer/ScrollContainer
var inventory: Inventory :
    get:
        return inventory
    set(new_inventory):
        disconnect_inventory_signals()
        inventory = new_inventory
        connect_inventory_signals()

        _refresh()
var editor_interface: EditorInterface
var gloot_undo_redo :
    get:
        return gloot_undo_redo
    set(new_gloot_undo_redo):
        gloot_undo_redo = new_gloot_undo_redo
        if _inventory_control is CtrlInventoryGrid:
            _inventory_control._gloot_undo_redo = gloot_undo_redo
var _inventory_control: Control


func connect_inventory_signals():
    if !inventory:
        return

    if inventory is InventoryStacked:
        inventory.capacity_changed.connect(Callable(self, "_refresh"))
    if inventory is InventoryGrid:
        inventory.size_changed.connect(Callable(self, "_refresh"))
    inventory.protoset_changed.connect(Callable(self, "_refresh"))

    if !inventory.item_protoset:
        return
    inventory.item_protoset.changed.connect(Callable(self, "_refresh"))


func disconnect_inventory_signals():
    if !inventory:
        return
        
    if inventory is InventoryStacked:
        inventory.capacity_changed.disconnect(Callable(self, "_refresh"))
    if inventory is InventoryGrid:
        inventory.size_changed.disconnect(Callable(self, "_refresh"))
    inventory.protoset_changed.disconnect(Callable(self, "_refresh"))

    if !inventory.item_protoset:
        return
    inventory.item_protoset.changed.disconnect(Callable(self, "_refresh"))


func _refresh() -> void:
    if !is_inside_tree() || inventory == null || inventory.item_protoset == null:
        return
        
    # Remove the inventory control, if present
    if _inventory_control:
        scroll_container.remove_child(_inventory_control)
        _inventory_control.queue_free()
        _inventory_control = null

    # Create the appropriate inventory control and populate it
    if inventory is InventoryGrid:
        _inventory_control = CtrlInventoryGrid.new()
        _inventory_control.grid_color = Color.GRAY
        _inventory_control.draw_selections = true
        # TODO: Find a better way for undoing/redoing item movements:
        _inventory_control._gloot_undo_redo = gloot_undo_redo
    elif inventory is InventoryStacked:
        _inventory_control = CtrlInventoryStacked.new()
    elif inventory is Inventory:
        _inventory_control = CtrlInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory
    _inventory_control.inventory_item_activated.connect(Callable(self, "_on_inventory_item_activated"))

    scroll_container.add_child(_inventory_control)

    # Set prototype_id_filter values
    prototype_id_filter.set_values(inventory.item_protoset._prototypes.keys())


func _on_inventory_item_activated(item: InventoryItem) -> void:
    assert(gloot_undo_redo)
    gloot_undo_redo.remove_inventory_item(inventory, item)


func _ready() -> void:
    prototype_id_filter.pick_icon = EditorIcons.get_icon(editor_interface, "Add")
    prototype_id_filter.filter_icon = EditorIcons.get_icon(editor_interface, "Search")
    btn_edit.icon = EditorIcons.get_icon(editor_interface, "Edit")
    btn_remove.icon = EditorIcons.get_icon(editor_interface, "Remove")

    prototype_id_filter.choice_picked.connect(Callable(self, "_on_prototype_id_picked"))
    btn_edit.pressed.connect(Callable(self, "_on_btn_edit"))
    btn_remove.pressed.connect(Callable(self, "_on_btn_remove"))
    _refresh()


func _on_prototype_id_picked(index: int) -> void:
    assert(gloot_undo_redo)
    var prototype_id = prototype_id_filter.values[index]
    gloot_undo_redo.add_inventory_item(inventory, prototype_id)
    

func _on_btn_edit() -> void:
    var selected_item: InventoryItem = _inventory_control.get_selected_inventory_item()
    if selected_item != null:
        # Call it deferred, so that the control can clean up
        call_deferred("_select_node", editor_interface, selected_item)


func _on_btn_remove() -> void:
    assert(gloot_undo_redo)
    var selected_item: InventoryItem = _inventory_control.get_selected_inventory_item()
    if selected_item != null:
        gloot_undo_redo.remove_inventory_item(inventory, selected_item)


static func _select_node(editor_interface: EditorInterface, node: Node) -> void:
    editor_interface.get_selection().clear()
    editor_interface.get_selection().add_node(node)
    editor_interface.edit_node(node)

