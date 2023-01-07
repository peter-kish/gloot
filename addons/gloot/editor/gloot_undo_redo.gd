extends Object

var undo_redo_manager: EditorUndoRedoManager

func add_inventory_item(inventory: Inventory, prototype_id: String) -> void:
    assert(undo_redo_manager)

    # Create an temporary InventoryItem just to serialize it
    var item = InventoryItem.new()
    item.protoset = inventory.item_protoset
    item.prototype_id = prototype_id
    item.name = prototype_id
    
    # Actually adding it to the inventory is important as it might add some properties (position)
    # and change the item name (in case of duplicate names).
    if !inventory.add_item(item):
        # Item can't be added. Nothing to do.
        item.free()
        return
            
    var item_data = item.serialize()
    inventory.remove_item(item)
    item.free()

    undo_redo_manager.create_action("Add Inventory Item")
    undo_redo_manager.add_do_method(self, "_add_item", inventory, item_data)
    undo_redo_manager.add_undo_method(self, "_remove_item", inventory, item_data)
    undo_redo_manager.commit_action()


func remove_inventory_item(inventory: Inventory, item: InventoryItem) -> void:
    assert(undo_redo_manager)

    var item_data = item.serialize()
    var item_index = inventory.get_item_index(item)
    undo_redo_manager.create_action("Remove Inventory Item")
    undo_redo_manager.add_do_method(self, "_remove_item", inventory, item_data)
    undo_redo_manager.add_undo_method(self, "_add_item", inventory, item_data, item_index)
    undo_redo_manager.commit_action()


func remove_inventory_items(inventory: Inventory, items: Array) -> void:
    assert(undo_redo_manager)

    var item_data: Array
    var item_indexes: Array
    var node_indexes: Array
    for item in items:
        item_data.append(item.serialize())
        item_indexes.append(inventory.get_item_index(item))
        node_indexes.append(item.get_index())

    undo_redo_manager.create_action("Remove Inventory Items")
    undo_redo_manager.add_do_method(self, "_remove_items", inventory, item_data)
    undo_redo_manager.add_undo_method(self, "_add_items", inventory, item_data, item_indexes, node_indexes)
    undo_redo_manager.commit_action()


func _add_item(inventory: Inventory, item_data: Dictionary, item_index: int = -1, node_index: int = -1) -> void:
    var item = InventoryItem.new()
    item.deserialize(item_data)
    inventory.add_item(item)

    if item_index >= 0 && item_index < inventory.get_item_count():
        inventory.move_item(inventory.get_item_index(item), item_index)

    if node_index >= 0 && node_index < inventory.get_child_count():
        inventory.move_child(item, node_index)


func _add_items(inventory: Inventory, item_data: Array, item_indexes: Array, node_indexes: Array) -> void:
    for i in range(item_data.size()):
        _add_item(inventory, item_data[i], item_indexes[i], node_indexes[i])


func _remove_item(inventory: Inventory, item_data: Dictionary) -> void:
    var item_data_hash = item_data.hash()
    for item in inventory.get_items():
        if item.serialize().hash() == item_data_hash:
            item.queue_free()
            return
    assert(false, "Failed to remove item!")

func _remove_items(inventory: Inventory, item_data: Array) -> void:
    for data in item_data:
        _remove_item(inventory, data)


func set_item_properties(item: InventoryItem, new_properties: Dictionary) -> void:
    undo_redo_manager.create_action("Set item properties")
    var inventory: Inventory = item.get_inventory()
    if inventory:
        var old_inventory_data: Dictionary = inventory.serialize()
        var item_data: Dictionary = item.serialize()
        undo_redo_manager.add_do_method(self, "_set_properties", inventory, item_data, new_properties)
        undo_redo_manager.add_undo_method(self, "_set_inventory", inventory, old_inventory_data)
    else:
        undo_redo_manager.add_undo_property(item, "properties", item.properties)
        undo_redo_manager.add_do_property(item, "properties", new_properties)
    undo_redo_manager.commit_action()


func _set_properties(inventory: Inventory, item_data: Dictionary, properties: Dictionary):
    var item_data_hash = item_data.hash()
    for item in inventory.get_items():
        if item.serialize().hash() == item_data_hash:
            item.properties = properties.duplicate()


func set_item_prototype_id(item: InventoryItem, new_prototype_id: String) -> void:
    undo_redo_manager.create_action("Set prototype_id")
    var inventory: Inventory = item.get_inventory()
    if inventory:
        var old_inventory_data: Dictionary = inventory.serialize()
        var item_data: Dictionary = item.serialize()
        undo_redo_manager.add_do_method(self, "_set_prototype_id", inventory, item_data, new_prototype_id)
        undo_redo_manager.add_undo_method(self, "_set_inventory", inventory, old_inventory_data)
    else:
        undo_redo_manager.add_undo_property(item, "prototype_id", item.prototype_id)
        undo_redo_manager.add_do_property(item, "prototype_id", new_prototype_id)
    undo_redo_manager.commit_action()


func _set_prototype_id(inventory: Inventory, item_data: Dictionary, new_prototype_id: String) -> void:
    var item_data_hash = item_data.hash()
    for item in inventory.get_items():
        if item.serialize().hash() == item_data_hash:
            item.prototype_id = new_prototype_id


func _set_inventory(inventory: Inventory, inventory_data: Dictionary) -> void:
    inventory.deserialize(inventory_data)


func set_item_slot_equipped_item(item_slot: ItemSlot, new_equipped_item: int) -> void:
    undo_redo_manager.create_action("Set equipped_item")
    undo_redo_manager.add_undo_property(item_slot, "equipped_item", item_slot.equipped_item)
    undo_redo_manager.add_do_property(item_slot, "equipped_item", new_equipped_item)
    undo_redo_manager.commit_action()


func move_inventory_item(inventory: InventoryGrid, item: InventoryItem, position: Vector2) -> void:
    var old_item_position = inventory.get_item_position(item)
    if old_item_position == position:
        return
    undo_redo_manager.create_action("Move Inventory Item")
    undo_redo_manager.add_undo_method(inventory, "move_item_to", item, old_item_position)
    undo_redo_manager.add_do_method(inventory, "move_item_to", item, position)
    undo_redo_manager.commit_action()


func rename_prototype(protoset: ItemProtoset, id: String, new_id: String) -> void:
    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Rename Prototype")
    undo_redo_manager.add_undo_method(self, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "rename_prototype", id, new_id)
    undo_redo_manager.commit_action()


func add_prototype(protoset: ItemProtoset, id: String) -> void:
    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Add Prototype")
    undo_redo_manager.add_undo_method(self, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.add_do_method(protoset, "add_prototype", id)
    undo_redo_manager.commit_action()


func remove_prototype(protoset: ItemProtoset, id: String) -> void:
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
    assert(protoset.has_prototype(prototype_id))
    var old_properties = protoset.get_prototype(prototype_id).duplicate()

    undo_redo_manager.create_action("Set prototype properties")
    undo_redo_manager.add_undo_method(self, "_set_prototype_properties", protoset, prototype_id, old_properties)
    undo_redo_manager.add_do_method(self, "_set_prototype_properties", protoset, prototype_id, new_properties)
    undo_redo_manager.commit_action()


func _set_prototype_properties(protoset: ItemProtoset,
        prototype_id: String,
        new_properties: Dictionary) -> void:
    protoset._prototypes[prototype_id] = new_properties
    protoset.emit_changed()
