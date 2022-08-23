extends Object


func add_inventory_item(inventory: Inventory, prototype_id: String) -> void:
    assert(GLoot._undo_redo)

    # Create an temporary InventoryItem just to serialize it
    var item = InventoryItem.new()
    item.protoset = inventory.item_protoset
    item.prototype_id = prototype_id
    item.name = prototype_id
    var item_data = item.serialize()
    item.free()

    GLoot._undo_redo.create_action("Add Inventory Item")
    GLoot._undo_redo.add_do_method(self, "_add_item", inventory, item_data)
    GLoot._undo_redo.add_undo_method(self, "_remove_item", inventory, item_data)
    GLoot._undo_redo.commit_action()


func remove_inventory_item(inventory: Inventory, item: InventoryItem) -> void:
    assert(GLoot._undo_redo)

    var item_data = item.serialize()
    var item_index = inventory.get_item_index(item)
    GLoot._undo_redo.create_action("Remove Inventory Item")
    GLoot._undo_redo.add_do_method(self, "_remove_item", inventory, item_data)
    GLoot._undo_redo.add_undo_method(self, "_add_item", inventory, item_data, item_index)
    GLoot._undo_redo.commit_action()


func remove_inventory_items(inventory: Inventory, items: Array) -> void:
    assert(GLoot._undo_redo)

    var item_data: Array
    var item_indexes: Array
    var node_indexes: Array
    for item in items:
        item_data.append(item.serialize())
        item_indexes.append(inventory.get_item_index(item))
        node_indexes.append(item.get_index())

    GLoot._undo_redo.create_action("Remove Inventory Items")
    GLoot._undo_redo.add_do_method(self, "_remove_items", inventory, item_data)
    GLoot._undo_redo.add_undo_method(self, "_add_items", inventory, item_data, item_indexes, node_indexes)
    GLoot._undo_redo.commit_action()


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

func _remove_items(inventory: Inventory, item_data: Array) -> void:
    for data in item_data:
        _remove_item(inventory, data)


func set_item_properties(item: InventoryItem, new_properties: Dictionary) -> void:
    assert(GLoot._undo_redo)
    GLoot._undo_redo.create_action("Set item properties")
    GLoot._undo_redo.add_undo_property(item, "properties", item.properties)
    GLoot._undo_redo.add_do_property(item, "properties", new_properties)
    GLoot._undo_redo.commit_action()


func set_item_prototype_id(item: InventoryItem, new_prototype_id: String) -> void:
    assert(GLoot._undo_redo)
    GLoot._undo_redo.create_action("Set prototype_id")
    GLoot._undo_redo.add_undo_property(item, "prototype_id", item.prototype_id)
    GLoot._undo_redo.add_do_property(item, "prototype_id", new_prototype_id)
    GLoot._undo_redo.commit_action()


func set_item_slot_equipped_item(item_slot: ItemSlot, new_equipped_item: int) -> void:
    assert(GLoot._undo_redo)
    GLoot._undo_redo.create_action("Set equipped_item")
    GLoot._undo_redo.add_undo_property(item_slot, "equipped_item", item_slot.equipped_item)
    GLoot._undo_redo.add_do_property(item_slot, "equipped_item", new_equipped_item)
    GLoot._undo_redo.commit_action()


func move_inventory_item(inventory: InventoryGrid, item: InventoryItem, position: Vector2) -> void:
    assert(GLoot._undo_redo)
    
    var old_item_position = inventory.get_item_position(item)
    if old_item_position == position:
        return
    GLoot._undo_redo.create_action("Move Inventory Item")
    GLoot._undo_redo.add_undo_method(inventory, "move_item_to", item, old_item_position)
    GLoot._undo_redo.add_do_method(inventory, "move_item_to", item, position)
    GLoot._undo_redo.commit_action()
