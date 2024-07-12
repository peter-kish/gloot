@tool
extends Object

const GlootUndoRedo = preload("res://addons/gloot/editor/gloot_undo_redo.gd")


static func _get_undo_redo_manager():
    var gloot = load("res://addons/gloot/gloot.gd")
    assert(gloot.instance())
    var undo_redo_manager = gloot.instance().get_undo_redo()
    assert(undo_redo_manager)
    return undo_redo_manager


static func add_inventory_item(inventory: Inventory, prototype_id: String) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inv_state := inventory.serialize()
    if inventory.create_and_add_item(prototype_id) == null:
        return
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Add Inventory Item")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


static func remove_inventory_item(inventory: Inventory, item: InventoryItem) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inv_state := inventory.serialize()
    if !inventory.remove_item(item):
        return
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Remove Inventory Item")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


static func remove_inventory_items(inventory: Inventory, items: Array[InventoryItem]) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inv_state := inventory.serialize()
    for item in items:
        var remove_item_success = inventory.remove_item(item)
        assert(remove_item_success)
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Remove Inventory Items")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


static func set_item_properties(item: InventoryItem, new_properties: Dictionary) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var inventory: Inventory = item.get_inventory()
    if inventory:
        undo_redo_manager.create_action("Set item properties")
        undo_redo_manager.add_do_method(GlootUndoRedo, "_set_item_properties", inventory, inventory.get_item_index(item), new_properties)
        undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_item_properties", inventory, inventory.get_item_index(item), item.properties)
        undo_redo_manager.commit_action()
    else:
        undo_redo_manager.create_action("Set item properties")
        undo_redo_manager.add_undo_property(item, "properties", item.properties)
        undo_redo_manager.add_do_property(item, "properties", new_properties)
        undo_redo_manager.commit_action()


static func set_item_prototype_id(item: InventoryItem, new_prototype_id: String) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var inventory: Inventory = item.get_inventory()
    if inventory:
        undo_redo_manager.create_action("Set prototype_id")
        undo_redo_manager.add_do_method(GlootUndoRedo, "_set_item_prototype_id", inventory, inventory.get_item_index(item), new_prototype_id)
        undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_item_prototype_id", inventory, inventory.get_item_index(item), item.prototype_id)
        undo_redo_manager.commit_action()
    else:
        undo_redo_manager.create_action("Set prototype_id")
        undo_redo_manager.add_undo_property(item, "prototype_id", item.prototype_id)
        undo_redo_manager.add_do_property(item, "prototype_id", new_prototype_id)
        undo_redo_manager.commit_action()


static func _set_inventory(inventory: Inventory, inventory_data: Dictionary) -> void:
    inventory.deserialize(inventory_data)


static func _set_item_prototype_id(inventory: Inventory, item_index: int, new_prototype_id: String):
    assert(item_index < inventory.get_item_count())
    inventory.get_items()[item_index].prototype_id = new_prototype_id


static func _set_item_properties(inventory: Inventory, item_index: int, new_properties: Dictionary):
    assert(item_index < inventory.get_item_count())
    inventory.get_items()[item_index].properties = new_properties.duplicate()


static func equip_item_in_item_slot(item_slot: ItemSlotBase, item: InventoryItem) -> void:
    var undo_redo_manager = _get_undo_redo_manager()
    
    var old_slot_state := item_slot.serialize()
    if !item_slot.equip(item):
        return
    var new_slot_state := item_slot.serialize()
        
    undo_redo_manager.create_action("Equip Inventory Item")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_item_slot", item_slot, new_slot_state)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_item_slot", item_slot, old_slot_state)
    undo_redo_manager.commit_action()


static func clear_item_slot(item_slot: ItemSlotBase) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_slot_state := item_slot.serialize()
    if !item_slot.clear():
        return
    var new_slot_state := item_slot.serialize()

    undo_redo_manager.create_action("Clear Inventory Item")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_item_slot", item_slot, new_slot_state)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_item_slot", item_slot, old_slot_state)
    undo_redo_manager.commit_action()


static func _set_item_slot(item_slot: ItemSlotBase, item_slot_data: Dictionary) -> void:
    item_slot.deserialize(item_slot_data)


static func move_inventory_item(inventory: InventoryGrid, item: InventoryItem, to: Vector2i) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_position := inventory.get_item_position(item)
    if old_position == to:
        return
    var item_index := inventory.get_item_index(item)

    undo_redo_manager.create_action("Move Inventory Item")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_move_item", inventory, item_index, to)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_move_item", inventory, item_index, old_position)
    undo_redo_manager.commit_action()


static func swap_inventory_items(item1: InventoryItem, item2: InventoryItem) -> void:

    var undo_redo_manager = _get_undo_redo_manager()

    var inventories: Array[Inventory] = [item1.get_inventory(), item2.get_inventory()]
    var old_inv_states: Array[Dictionary] = [{}, {}]
    var new_inv_states: Array[Dictionary] = [{}, {}]
    old_inv_states[0] = inventories[0].serialize()
    old_inv_states[1] = inventories[1].serialize()
    if !InventoryItem.swap(item1, item2):
        return
    new_inv_states[0] = inventories[0].serialize()
    new_inv_states[1] = inventories[1].serialize()

    undo_redo_manager.create_action("Swap Inventory Items")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_inventories", inventories, new_inv_states)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_inventories", inventories, old_inv_states)
    undo_redo_manager.commit_action()


static func _set_inventories(inventories: Array[Inventory], inventory_data: Array[Dictionary]) -> void:
    assert(inventories.size() == inventory_data.size())
    for i in range(inventories.size()):
        inventories[i].deserialize(inventory_data[i])


static func rotate_inventory_item(inventory: InventoryGrid, item: InventoryItem) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    if !inventory.can_rotate_item(item):
        return

    var old_rotation := inventory.is_item_rotated(item)
    var item_index := inventory.get_item_index(item)

    undo_redo_manager.create_action("Rotate Inventory Item")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_item_rotation", inventory, item_index, !old_rotation)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_item_rotation", inventory, item_index, old_rotation)
    undo_redo_manager.commit_action()


static func _move_item(inventory: InventoryGrid, item_index: int, to: Vector2i) -> void:
    assert(item_index >= 0 && item_index < inventory.get_item_count())
    var item = inventory.get_items()[item_index]
    inventory.move_item_to(item, to)


static func _set_item_rotation(inventory: InventoryGrid, item_index: int, rotation: bool) -> void:
    assert(item_index >= 0 && item_index < inventory.get_item_count())
    var item = inventory.get_items()[item_index]
    inventory.set_item_rotation(item, rotation)


static func join_inventory_items(
    inventory: InventoryGridStacked,
    item_dst: InventoryItem,
    item_src: InventoryItem
) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inv_state := inventory.serialize()
    if !inventory.join(item_dst, item_src):
        return
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Join Inventory Items")
    undo_redo_manager.add_do_method(GlootUndoRedo, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


static func rename_prototype(protoset: ItemProtoset, id: String, new_id: String) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Rename Prototype")
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "rename_prototype", id, new_id)
    undo_redo_manager.commit_action()


static func add_prototype(protoset: ItemProtoset, id: String) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Add Prototype")
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "add_prototype", id)
    undo_redo_manager.commit_action()


static func remove_prototype(protoset: ItemProtoset, id: String) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Remove Prototype")
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "remove_prototype", id)
    undo_redo_manager.commit_action()


static func duplicate_prototype(protoset: ItemProtoset, id: String) -> void:
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Duplicate Prototype")
    undo_redo_manager.add_undo_method(GlootUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "duplicate_prototype", id)
    undo_redo_manager.commit_action()


static func _prototypes_deep_copy(protoset: ItemProtoset) -> Dictionary:
    var result = protoset._prototypes.duplicate()
    for prototype_id in result.keys():
        result[prototype_id] = protoset._prototypes[prototype_id].duplicate()
    return result


static func _set_prototypes(protoset: ItemProtoset, prototypes: Dictionary) -> void:
    protoset._prototypes = prototypes


static func set_prototype_properties(protoset: ItemProtoset,
        prototype_id: String,
        new_properties: Dictionary) -> void:
    var undo_redo_manager = _get_undo_redo_manager()
    assert(protoset.has_prototype(prototype_id))
    var old_properties = protoset.get_prototype(prototype_id).duplicate()

    undo_redo_manager.create_action("Set prototype properties")
    undo_redo_manager.add_undo_method(
        protoset,
        "set_prototype_properties",
        prototype_id,
        old_properties
    )
    undo_redo_manager.add_do_method(
        protoset,
        "set_prototype_properties",
        prototype_id,
        new_properties
    )
    undo_redo_manager.commit_action()

