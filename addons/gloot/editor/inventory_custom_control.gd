extends Control
tool


onready var prototype_id_filter = $HBoxContainer/ChoiceFilter
onready var inventory_control_container = $HBoxContainer/VBoxContainer
onready var btn_edit = $HBoxContainer/VBoxContainer/HBoxContainer/BtnEdit
onready var btn_remove = $HBoxContainer/VBoxContainer/HBoxContainer/BtnRemove
onready var scroll_container = $HBoxContainer/VBoxContainer/ScrollContainer
var inventory: Inventory setget _set_inventory
var editor_interface: EditorInterface
var _inventory_control: Control


func _set_inventory(new_inventory: Inventory) -> void:
    disconnect_inventory_signals()
    inventory = new_inventory
    connect_inventory_signals()

    _refresh()


func connect_inventory_signals():
    if !inventory:
        return

    if inventory is InventoryStacked:
        inventory.connect("capacity_changed", self, "_refresh")
    if inventory is InventoryGrid:
        inventory.connect("size_changed", self, "_refresh")
    inventory.connect("protoset_changed", self, "_on_inventory_protoset_changed")


func disconnect_inventory_signals():
    if !inventory:
        return
        
    if inventory is InventoryStacked:
        inventory.disconnect("capacity_changed", self, "_refresh")
    if inventory is InventoryGrid:
        inventory.disconnect("size_changed", self, "_refresh")
    inventory.disconnect("protoset_changed", self, "_on_inventory_protoset_changed")


func _refresh() -> void:
    if !is_inside_tree() || inventory == null || inventory.item_protoset == null:
        return
        
    # Remove the inventory control, if present
    if _inventory_control:
        scroll_container.remove_child(_inventory_control)
        _inventory_control.free()
        _inventory_control = null

    # Create the appropriate inventory control and populate it
    if inventory is InventoryGrid:
        _inventory_control = CtrlInventoryGrid.new()
        _inventory_control.grid_color = Color.gray
        _inventory_control.selections_enabled = true
    elif inventory is InventoryStacked:
        _inventory_control = CtrlInventoryStacked.new()
    elif inventory is Inventory:
        _inventory_control = CtrlInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory

    scroll_container.add_child(_inventory_control)

    # Set prototype_id_filter values
    prototype_id_filter.values = inventory.item_protoset._prototypes.keys()


func _ready() -> void:
    prototype_id_filter.connect("choice_picked", self, "_on_prototype_id_picked")
    btn_edit.connect("pressed", self, "_on_btn_edit")
    btn_remove.connect("pressed", self, "_on_btn_remove")
    _refresh()


func _on_prototype_id_picked(index: int) -> void:
    var item = InventoryItem.new()
    item.protoset = inventory.item_protoset
    item.prototype_id = prototype_id_filter.values[index]
    item.name = item.prototype_id
    inventory.add_item(item)
    

func _on_btn_edit() -> void:
    var selected_items: Array = _inventory_control.get_selected_inventory_items()
    if selected_items.size() > 0:
        var item: Node = selected_items[0]
        # Call it deferred, so that the control can clean up
        call_deferred("_select_node", editor_interface, item)


func _on_btn_remove() -> void:
    var selected_items: Array = _inventory_control.get_selected_inventory_items()
    for item in selected_items:
        item.queue_free()


static func _select_node(editor_interface: EditorInterface, node: Node) -> void:
    editor_interface.get_selection().clear()
    editor_interface.get_selection().add_node(node)
    editor_interface.edit_node(node)