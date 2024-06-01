extends Object

const Undoables = preload("res://addons/gloot/editor/undoables.gd")


static func _get_undo_redo_manager() -> EditorUndoRedoManager:
    if Engine.is_editor_hint():
        var Gloot = load("res://addons/gloot/gloot.gd")
        if Gloot.instance() == null:
            return null
        var undo_redo_manager = Gloot.instance().get_undo_redo()
        if undo_redo_manager == null:
            return null
        return undo_redo_manager
    else:
        return null


static func exec_inventory_undoable(inventories: Array[Inventory], action_name: String, callable: Callable) -> bool:
    var undo_redo_manager = _get_undo_redo_manager()
    if undo_redo_manager == null:
        return callable.call()

    var old_inv_states := _serialize_inventories(inventories)
    var result: bool = callable.call()
    if !result:
        return false
    var new_inv_states := _serialize_inventories(inventories)

    undo_redo_manager.create_action(action_name)
    undo_redo_manager.add_do_method(Undoables, "_set_inventories", inventories, new_inv_states)
    undo_redo_manager.add_undo_method(Undoables, "_set_inventories", inventories, old_inv_states)
    undo_redo_manager.commit_action()

    return true


static func _set_inventories(inventories: Array[Inventory], inventory_data: Array[Dictionary]) -> void:
    assert(inventories.size() == inventory_data.size())
    for i in range(inventories.size()):
        inventories[i].deserialize(inventory_data[i])


static func _serialize_inventories(inventories: Array[Inventory]) -> Array[Dictionary]:
    var result: Array[Dictionary]
    for inventory in inventories:
        result.push_back(inventory.serialize())
    return result


static func exec_item_undoable(item: InventoryItem, action_name: String, callable: Callable) -> bool:
    var undo_redo_manager = _get_undo_redo_manager()
    if undo_redo_manager == null:
        return callable.call()

    var old_item_state := item.serialize()
    var result: bool = callable.call()
    if !result:
        return false
    var new_item_state := item.serialize()

    undo_redo_manager.create_action(action_name)
    undo_redo_manager.add_do_method(Undoables, "_set_item", item, new_item_state)
    undo_redo_manager.add_undo_method(Undoables, "_set_item", item, old_item_state)
    undo_redo_manager.commit_action()

    return true


static func _set_item(item: InventoryItem, data: Dictionary) -> void:
    item.deserialize(data)


static func exec_slot_undoable(slot: ItemSlot, action_name: String, callable: Callable) -> bool:
    var undo_redo_manager = _get_undo_redo_manager()
    if undo_redo_manager == null:
        return callable.call()

    var old_slot_state := slot.serialize()
    var result: bool = callable.call()
    if !result:
        return false
    var new_slot_state := slot.serialize()

    undo_redo_manager.create_action(action_name)
    undo_redo_manager.add_do_method(Undoables, "_set_slot", slot, new_slot_state)
    undo_redo_manager.add_undo_method(Undoables, "_set_slot", slot, old_slot_state)
    undo_redo_manager.commit_action()

    return true


static func _set_slot(slot: ItemSlot, data: Dictionary) -> void:
    slot.deserialize(data)