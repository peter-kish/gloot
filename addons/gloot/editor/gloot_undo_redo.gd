extends Object

var undo_redo_manager: EditorUndoRedoManager

func add_inventory_item(inventory: Inventory, prototype_id: String) -> void:
    assert(undo_redo_manager)

    var old_inv_state := inventory.serialize()
    if inventory.create_and_add_item(prototype_id) == null:
        return
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Add Inventory Item")
    undo_redo_manager.add_do_method(self, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(self, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


func remove_inventory_item(inventory: Inventory, item: InventoryItem) -> void:
    assert(undo_redo_manager)

    var old_inv_state := inventory.serialize()
    if !inventory.remove_item(item):
        return
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Remove Inventory Item")
    undo_redo_manager.add_do_method(self, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(self, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


func remove_inventory_items(inventory: Inventory, items: Array[InventoryItem]) -> void:
    assert(undo_redo_manager)

    var old_inv_state := inventory.serialize()
    for item in items:
        assert(inventory.remove_item(item))
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Remove Inventory Items")
    undo_redo_manager.add_do_method(self, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(self, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


func set_item_properties(item: InventoryItem, new_properties: Dictionary) -> void:
    assert(undo_redo_manager)

    var inventory: Inventory = item.get_inventory()
    if inventory:
        undo_redo_manager.create_action("Set item properties")
        undo_redo_manager.add_do_method(self, "_set_item_properties", inventory, inventory.get_item_index(item), new_properties)
        undo_redo_manager.add_undo_method(self, "_set_item_properties", inventory, inventory.get_item_index(item), item.properties)
        undo_redo_manager.commit_action()
    else:
        undo_redo_manager.create_action("Set item properties")
        undo_redo_manager.add_undo_property(item, "properties", item.properties)
        undo_redo_manager.add_do_property(item, "properties", new_properties)
        undo_redo_manager.commit_action()


func set_item_prototype_id(item: InventoryItem, new_prototype_id: String) -> void:
    assert(undo_redo_manager)

    var inventory: Inventory = item.get_inventory()
    if inventory:
        undo_redo_manager.create_action("Set prototype_id")
        undo_redo_manager.add_do_method(self, "_set_item_prototype_id", inventory, inventory.get_item_index(item), new_prototype_id)
        undo_redo_manager.add_undo_method(self, "_set_item_prototype_id", inventory, inventory.get_item_index(item), item.prototype_id)
        undo_redo_manager.commit_action()
    else:
        undo_redo_manager.create_action("Set prototype_id")
        undo_redo_manager.add_undo_property(item, "prototype_id", item.prototype_id)
        undo_redo_manager.add_do_property(item, "prototype_id", new_prototype_id)
        undo_redo_manager.commit_action()


func _set_inventory(inventory: Inventory, inventory_data: Dictionary) -> void:
    inventory.deserialize(inventory_data)


func _set_item_prototype_id(inventory: Inventory, item_index: int, new_prototype_id: String):
    assert(item_index < inventory.get_item_count())
    inventory.get_items()[item_index].prototype_id = new_prototype_id


func _set_item_properties(inventory: Inventory, item_index: int, new_properties: Dictionary):
    assert(item_index < inventory.get_item_count())
    inventory.get_items()[item_index].properties = new_properties.duplicate()


func set_item_slot_equipped_item(item_slot: ItemSlot, new_equipped_item: int) -> void:
    assert(undo_redo_manager)

    undo_redo_manager.create_action("Set equipped_item")
    undo_redo_manager.add_undo_property(item_slot, "equipped_item", item_slot.equipped_item)
    undo_redo_manager.add_do_property(item_slot, "equipped_item", new_equipped_item)
    undo_redo_manager.commit_action()


func move_inventory_item(inventory: InventoryGrid, item: InventoryItem, to: Vector2i) -> void:
    assert(undo_redo_manager)

    var old_position := inventory.get_item_position(item)
    if old_position == to:
        return
    var item_index := inventory.get_item_index(item)

    undo_redo_manager.create_action("Move Inventory Item")
    undo_redo_manager.add_do_method(self, "_move_item", inventory, item_index, to)
    undo_redo_manager.add_undo_method(self, "_move_item", inventory, item_index, old_position)
    undo_redo_manager.commit_action()


func _move_item(inventory: InventoryGrid, item_index: int, to: Vector2i) -> void:
    assert(item_index >= 0 && item_index < inventory.get_item_count())
    var item = inventory.get_items()[item_index]
    inventory.move_item_to(item, to)


func join_inventory_items(
    inventory: InventoryGridStacked,
    item_dst: InventoryItem,
    item_src: InventoryItem
) -> void:
    assert(undo_redo_manager)

    var old_inv_state := inventory.serialize()
    if !inventory.join(item_dst, item_src):
        return
    var new_inv_state := inventory.serialize()

    undo_redo_manager.create_action("Join Inventory Items")
    undo_redo_manager.add_do_method(self, "_set_inventory", inventory, new_inv_state)
    undo_redo_manager.add_undo_method(self, "_set_inventory", inventory, old_inv_state)
    undo_redo_manager.commit_action()


func rename_prototype(protoset: ItemProtoset, id: String, new_id: String) -> void:
    assert(undo_redo_manager)

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Rename Prototype")
    undo_redo_manager.add_undo_method(self, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "rename_prototype", id, new_id)
    undo_redo_manager.commit_action()


func add_prototype(protoset: ItemProtoset, id: String) -> void:
    assert(undo_redo_manager)

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Add Prototype")
    undo_redo_manager.add_undo_method(self, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "add_prototype", id)
    undo_redo_manager.commit_action()


func remove_prototype(protoset: ItemProtoset, id: String) -> void:
    assert(undo_redo_manager)

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Remove Prototype")
    undo_redo_manager.add_undo_method(self, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "remove_prototype", id)
    undo_redo_manager.commit_action()


func _prototypes_deep_copy(protoset: ItemProtoset) -> Dictionary:
    var result = protoset._prototypes.duplicate()
    for prototype_id in result.keys():
        result[prototype_id] = protoset._prototypes[prototype_id].duplicate()
    return result


func _set_prototypes(protoset: ItemProtoset, prototypes: Dictionary) -> void:
    protoset._prototypes = prototypes


func set_prototype_properties(protoset: ItemProtoset,
        prototype_id: String,
        new_properties: Dictionary) -> void:
    assert(undo_redo_manager)
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

