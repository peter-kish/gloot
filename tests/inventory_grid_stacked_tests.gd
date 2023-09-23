extends TestSuite

var inventory_3x3: InventoryGridStacked
var inventory_3x3_2: InventoryGridStacked
var item_1x1: InventoryItem
var item_2x2: InventoryItem
var item_2x2_2: InventoryItem

const TEST_PROTOSET = preload("res://tests/data/item_definitions_grid.tres")


func init_suite():
    tests = [
        "test_has_place_for",
        "test_add_item_automerge",
        "test_stack_split",
        "test_stack_cant_split",
        "test_stack_join",
        "test_stack_cant_join",
        "test_automerge",
        "test_autosplitmerge",
    ]


func init_test():
    inventory_3x3 = create_inventory_grid_stacked(TEST_PROTOSET, Vector2i(3, 3))
    inventory_3x3_2 = create_inventory_grid_stacked(TEST_PROTOSET, Vector2i(3, 3))
    
    item_1x1 = create_item(TEST_PROTOSET, "item_1x1")
    item_2x2 = create_item(TEST_PROTOSET, "item_2x2")
    item_2x2_2 = create_item(TEST_PROTOSET, "item_2x2")


func cleanup_test() -> void:
    free_inventory(inventory_3x3)
    free_inventory(inventory_3x3_2)

    free_item(item_1x1)
    free_item(item_2x2)
    free_item(item_2x2_2)


func test_has_place_for() -> void:
    # Empty inventory
    assert(inventory_3x3.has_place_for(item_1x1))
    assert(inventory_3x3.has_place_for(item_2x2))
    
    # Inventory containing 1x1 item
    assert(inventory_3x3.add_item(item_1x1))
    assert(inventory_3x3.has_place_for(item_2x2))
    
    # Inventory containing 2x2 item
    InventoryGridStacked.set_item_max_stack_size(item_2x2, 1)
    assert(inventory_3x3.add_item(item_2x2))
    assert(!inventory_3x3.has_place_for(item_2x2_2))

    # Inventory containing 2x2 item with extended max_stack_size
    InventoryGridStacked.set_item_max_stack_size(item_2x2, 10)
    assert(inventory_3x3.has_place_for(item_2x2_2))


func test_add_item_automerge() -> void:
    # Empty inventory
    assert(inventory_3x3.add_item_automerge(item_2x2))
    assert(inventory_3x3.get_item_count() == 1)
    
    # Inventory containing 2x2 item
    assert(inventory_3x3.add_item_automerge(item_2x2_2))
    assert(inventory_3x3.get_item_count() == 1)
    assert(!is_node_valid(item_2x2_2))

    item_2x2_2 = InventoryItem.new()
    item_2x2_2.protoset = TEST_PROTOSET
    item_2x2_2.prototype_id = "item_2x2"

    # No stack space, no grid space
    assert(InventoryGridStacked.set_item_stack_size(item_2x2,
        InventoryGridStacked.get_item_max_stack_size(item_2x2)))
    assert(!inventory_3x3.add_item_automerge(item_2x2_2))

    # No stack space but grid space available
    assert(inventory_3x3.add_item_automerge(item_1x1))


func test_stack_split() -> void:
    assert(inventory_3x3.add_item(item_1x1))
    assert(InventoryGridStacked.set_item_stack_size(item_1x1, 2))
    var new_item = inventory_3x3.split(item_1x1, 1)
    assert(new_item != null)
    assert(inventory_3x3.get_item_count() == 2)
    assert(inventory_3x3.has_item(new_item))


func test_stack_cant_split() -> void:
    # TODO: FIX
    # assert(inventory_3x3.add_item(item_2x2))
    # assert(InventoryGridStacked.set_item_stack_size(item_2x2, 2))
    # var new_item = inventory_3x3.split(item_2x2, 1)
    # assert(new_item == null)
    # assert(inventory_3x3.get_item_count() == 1)
    pass


func test_stack_join() -> void:
    var item_1x1_2 = item_1x1.duplicate()
    assert(inventory_3x3.add_item(item_1x1))
    assert(inventory_3x3.add_item(item_1x1_2))
    assert(inventory_3x3.join(item_1x1, item_1x1_2))


func test_stack_cant_join() -> void:
    InventoryGridStacked.set_item_max_stack_size(item_1x1, 1)
    var item_1x1_2 = item_1x1.duplicate()
    assert(inventory_3x3.add_item(item_1x1))
    assert(inventory_3x3.add_item(item_1x1_2))
    assert(!inventory_3x3.join(item_1x1, item_1x1_2))


func test_automerge() -> void:
    InventoryGridStacked.set_item_max_stack_size(item_2x2, 3)
    assert(InventoryGridStacked.set_item_stack_size(item_2x2, 1))
    assert(inventory_3x3.add_item(item_2x2))
    assert(InventoryGridStacked.set_item_stack_size(item_2x2_2, 3))
    assert(inventory_3x3_2.add_item(item_2x2_2))
    
    # Not enough space
    assert(!inventory_3x3_2.transfer_automerge(item_2x2_2, inventory_3x3))

    # Enough space
    assert(InventoryGridStacked.set_item_stack_size(item_2x2_2, 2))
    assert(inventory_3x3_2.transfer_automerge(item_2x2_2, inventory_3x3))
    assert(InventoryGridStacked.get_item_stack_size(item_2x2) == 3)
    assert(!is_node_valid(item_2x2_2))


func test_autosplitmerge() -> void:
    InventoryGridStacked.set_item_max_stack_size(item_2x2, 3)
    assert(InventoryGridStacked.set_item_stack_size(item_2x2, 1))
    assert(inventory_3x3.add_item(item_2x2))
    assert(InventoryGridStacked.set_item_stack_size(item_2x2_2, 3))
    assert(inventory_3x3_2.add_item(item_2x2_2))

    assert(inventory_3x3_2.transfer_autosplitmerge(item_2x2_2, inventory_3x3))
    assert(InventoryGridStacked.get_item_stack_size(item_2x2) == 3)
    assert(InventoryGridStacked.get_item_stack_size(item_2x2_2) == 1)

