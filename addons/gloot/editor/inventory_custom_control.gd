extends Control
tool


onready var prototype_id_filter = $HBoxContainer/ChoiceFilter
onready var inventory_control_container = $HBoxContainer/VBoxContainer
onready var btn_edit = $HBoxContainer/VBoxContainer/HBoxContainer/BtnEdit
onready var btn_remove = $HBoxContainer/VBoxContainer/HBoxContainer/BtnRemove
onready var scroll_container = $HBoxContainer/VBoxContainer/ScrollContainer
var inventory: Inventory setget _set_inventory
var editor_interface: EditorInterface
var undo_redo: UndoRedo
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
        # TODO: Find a better way for undoing/redoing item movements:
        _inventory_control._undo_redo = undo_redo
    elif inventory is InventoryStacked:
        _inventory_control = CtrlInventoryStacked.new()
    elif inventory is Inventory:
        _inventory_control = CtrlInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory
    _inventory_control.connect("inventory_item_activated", self, "_on_inventory_item_activated")

    scroll_container.add_child(_inventory_control)

    # Set prototype_id_filter values
    prototype_id_filter.values = inventory.item_protoset._prototypes.keys()


func _on_inventory_item_activated(item: InventoryItem) -> void:
    var item_data = item.serialize()
    undo_redo.create_action("Remove Inventory Item")
    undo_redo.add_do_method(self, "_remove_item", item_data)
    undo_redo.add_undo_method(self, "_add_item", item_data, inventory.get_item_index(item))
    undo_redo.commit_action()


func _ready() -> void:
    prototype_id_filter.connect("choice_picked", self, "_on_prototype_id_picked")
    btn_edit.connect("pressed", self, "_on_btn_edit")
    btn_remove.connect("pressed", self, "_on_btn_remove")
    _refresh()


func _on_prototype_id_picked(index: int) -> void:
    # Create an temporary InventoryItem just to calculate its hash
    var item = InventoryItem.new()
    item.protoset = inventory.item_protoset
    item.prototype_id = prototype_id_filter.values[index]
    item.name = item.prototype_id
    var item_data = item.serialize()
    item.free()

    undo_redo.create_action("Add Inventory Item")
    undo_redo.add_do_method(self, "_add_item", item_data)
    undo_redo.add_undo_method(self, "_remove_item", item_data)
    undo_redo.commit_action()
    

func _on_btn_edit() -> void:
    var selected_items: Array = _inventory_control.get_selected_inventory_items()
    if selected_items.size() > 0:
        var item: Node = selected_items[0]
        # Call it deferred, so that the control can clean up
        call_deferred("_select_node", editor_interface, item)


func _on_btn_remove() -> void:
    var selected_items: Array = _inventory_control.get_selected_inventory_items()
    var item_data: Array
    var item_indexes: Array
    var node_indexes: Array
    for item in selected_items:
        item_data.append(item.serialize())
        item_indexes.append(inventory.get_item_index(item))
        node_indexes.append(item.get_index())

    undo_redo.create_action("Remove Inventory Items")
    undo_redo.add_do_method(self, "_remove_items", item_data)
    undo_redo.add_undo_method(self, "_add_items", item_data, item_indexes, node_indexes)
    undo_redo.commit_action()


static func _select_node(editor_interface: EditorInterface, node: Node) -> void:
    editor_interface.get_selection().clear()
    editor_interface.get_selection().add_node(node)
    editor_interface.edit_node(node)


func _add_item(item_data: Dictionary, item_index: int = -1, node_index: int = -1) -> void:
    var item = InventoryItem.new()
    item.deserialize(item_data)
    inventory.add_item(item)

    if item_index >= 0 && item_index < inventory.get_item_count():
        inventory.move_item(inventory.get_item_index(item), item_index)

    if node_index >= 0 && node_index < inventory.get_child_count():
        inventory.move_child(item, node_index) 


func _add_items(item_data: Array, item_indexes: Array, node_indexes: Array) -> void:
    for i in range(item_data.size()):
        _add_item(item_data[i], item_indexes[i], node_indexes[i])


func _remove_item(item_data: Dictionary) -> void:
    var item_data_hash = item_data.hash()
    for item in inventory.get_items():
        if item.serialize().hash() == item_data_hash:
            item.queue_free()
            return


func _remove_items(item_data: Array) -> void:
    for data in item_data:
        _remove_item(data)
