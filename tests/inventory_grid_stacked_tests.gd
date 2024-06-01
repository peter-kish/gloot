extends TestSuite

var inventory_3x3: Inventory
var inventory_3x3_2: Inventory
var item_1x1: InventoryItem
var item_2x2: InventoryItem
var item_2x2_2: InventoryItem

const TEST_PROTOTREE = preload("res://tests/data/prototree_grid.json")


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
    inventory_3x3 = create_inventory_grid(TEST_PROTOTREE, Vector2i(3, 3))
    inventory_3x3_2 = create_inventory_grid(TEST_PROTOTREE, Vector2i(3, 3))
    
    item_1x1 = create_item(TEST_PROTOTREE, "/item_1x1")
    item_2x2 = create_item(TEST_PROTOTREE, "/item_2x2")
    item_2x2_2 = create_item(TEST_PROTOTREE, "/item_2x2")


func cleanup_test() -> void:
    free_inventory(inventory_3x3)
    free_inventory(inventory_3x3_2)


func test_has_place_for() -> void:
    # Empty inventory
    assert(inventory_3x3.can_add_item(item_1x1))
    assert(inventory_3x3.can_add_item(item_2x2))
    
    # Inventory containing 1x1 item
    assert(inventory_3x3.add_item(item_1x1))
    assert(inventory_3x3.can_add_item(item_2x2))
    
    # Inventory containing 2x2 item
    Inventory.set_item_max_stack_size(item_2x2, ItemCount.new(1))
    assert(inventory_3x3.add_item(item_2x2))
    assert(!inventory_3x3.can_add_item(item_2x2_2))

    # Inventory containing 2x2 item with extended max_stack_size
    Inventory.set_item_max_stack_size(item_2x2, ItemCount.new(10))
    assert(inventory_3x3.can_add_item(item_2x2_2))


func test_add_item_automerge() -> void:
    Inventory.set_item_max_stack_size(item_1x1, ItemCount.new(100))
    Inventory.set_item_max_stack_size(item_2x2, ItemCount.new(100))
    Inventory.set_item_max_stack_size(item_2x2_2, ItemCount.new(100))

    # Empty inventory
    assert(inventory_3x3.add_item_automerge(item_2x2))
    assert(inventory_3x3.get_item_count() == 1)
    
    # Inventory containing 2x2 item
    assert(inventory_3x3.add_item_automerge(item_2x2_2))
    assert(inventory_3x3.get_item_count() == 1)
    assert(!inventory_3x3.has_item(item_2x2_2));

    item_2x2_2 = InventoryItem.new(TEST_PROTOTREE, "/item_2x2")

    # No stack space, no grid space
    assert(Inventory.set_item_stack_size(item_2x2,
        Inventory.get_item_max_stack_size(item_2x2)))
    assert(!inventory_3x3.add_item_automerge(item_2x2_2))

    # No stack space but grid space available
    assert(inventory_3x3.add_item_automerge(item_1x1))


func test_stack_split() -> void:
    assert(inventory_3x3.add_item(item_1x1))
    Inventory.set_item_max_stack_size(item_1x1, ItemCount.new(2))
    assert(Inventory.set_item_stack_size(item_1x1, ItemCount.new(2)))
    var new_item = inventory_3x3.split_inv_stack(item_1x1, ItemCount.new(1))
    assert(new_item != null)
    assert(inventory_3x3.get_item_count() == 2)
    assert(inventory_3x3.has_item(new_item))


func test_stack_cant_split() -> void:
    # TODO: FIX
    # assert(inventory_3x3.add_item(item_2x2))
    # assert(Inventory.set_item_stack_size(item_2x2, ItemCount.new(2)))
    # var new_item = inventory_3x3.split_inv_tack(item_2x2, ItemCount.new(1))
    # assert(new_item == null)
    # assert(inventory_3x3.get_item_count() == 1)
    pass


func test_stack_join() -> void:
    Inventory.set_item_max_stack_size(item_1x1, ItemCount.new(2))
    var item_1x1_2 = item_1x1.duplicate()
    assert(inventory_3x3.add_item(item_1x1))
    assert(inventory_3x3.add_item(item_1x1_2))
    assert(inventory_3x3.merge_inv_stacks(item_1x1, item_1x1_2))


func test_stack_cant_join() -> void:
    var item_1x1_2 = item_1x1.duplicate()
    assert(inventory_3x3.add_item(item_1x1))
    assert(inventory_3x3.add_item(item_1x1_2))
    assert(!inventory_3x3.merge_inv_stacks(item_1x1, item_1x1_2))


func test_automerge() -> void:
    Inventory.set_item_max_stack_size(item_1x1, ItemCount.new(100))
    Inventory.set_item_max_stack_size(item_2x2, ItemCount.new(100))
    Inventory.set_item_max_stack_size(item_2x2_2, ItemCount.new(100))

    Inventory.set_item_max_stack_size(item_2x2, ItemCount.new(3))
    assert(Inventory.set_item_stack_size(item_2x2, ItemCount.new(1)))
    assert(inventory_3x3.add_item(item_2x2))
    assert(Inventory.set_item_stack_size(item_2x2_2, ItemCount.new(3)))
    assert(inventory_3x3_2.add_item(item_2x2_2))
    
    # Not enough space
    assert(!inventory_3x3.add_item_automerge(item_2x2_2))

    # Enough space
    assert(Inventory.set_item_stack_size(item_2x2_2, ItemCount.new(2)))
    assert(inventory_3x3.add_item_automerge(item_2x2_2))
    assert(Inventory.get_item_stack_size(item_2x2).eq(ItemCount.new(3)))
    assert(!inventory_3x3_2.has_item(item_2x2_2))


func test_autosplitmerge() -> void:
    Inventory.set_item_max_stack_size(item_2x2, ItemCount.new(3))
    assert(Inventory.set_item_stack_size(item_2x2, ItemCount.new(1)))
    assert(inventory_3x3.add_item_autosplitmerge(item_2x2))
    Inventory.set_item_max_stack_size(item_2x2_2, ItemCount.new(3))
    assert(Inventory.set_item_stack_size(item_2x2_2, ItemCount.new(3)))
    assert(inventory_3x3_2.add_item_autosplitmerge(item_2x2_2))

    assert(inventory_3x3.add_item_autosplitmerge(item_2x2_2))
    assert(Inventory.get_item_stack_size(item_2x2).eq(ItemCount.new(3)))
    assert(Inventory.get_item_stack_size(item_2x2_2).eq(ItemCount.new(1)))

