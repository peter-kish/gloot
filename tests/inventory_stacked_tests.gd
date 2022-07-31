extends TestSuite

var inventory: InventoryStacked
var item: InventoryItem
var big_item: InventoryItem
var stackable_item: InventoryItem


func init_suite() -> void:
    inventory = $InventoryStacked
    item = $MinimalItem
    big_item = $BigItem
    stackable_item = $StackableItem

    tests = [
        "test_space",
        "test_big_item",
        "test_change_capacity",
        "test_unlimited_capacity",
        "test_invalid_capacity",
        "test_contents_changed_signal",
        "test_stack_split_join",
        "test_serialize"
    ]


func init_test() -> void:
    inventory.capacity = 10.0
    inventory.remove_all_items()


func test_space() -> void:
    assert(inventory.capacity == 10.0)
    assert(inventory.get_free_space() == 10.0)
    assert(inventory.occupied_space == 0.0)
    assert(inventory.has_place_for(item))
    assert(inventory.add_item(item))
    assert(inventory.occupied_space == 1.0)
    assert(inventory.get_free_space() == 9.0)


func test_big_item() -> void:
    assert(!inventory.has_place_for(big_item))
    assert(!inventory.add_item(big_item))


func test_change_capacity() -> void:
    inventory.capacity = 0.5
    assert(!inventory.has_place_for(item))
    assert(!inventory.add_item(item))


func test_unlimited_capacity() -> void:
    inventory.capacity = 0
    assert(inventory.has_place_for(item))
    assert(inventory.add_item(item))
    assert(inventory.has_place_for(big_item))
    assert(inventory.add_item(big_item))


func test_invalid_capacity() -> void:
    inventory.capacity = 21
    assert(inventory.add_item(big_item))
    inventory.capacity = 19
    assert(inventory.capacity == 21)


func test_contents_changed_signal() -> void:
    # These checks cause some warnings:
    #
    # assert(inventory.add_item(item))
    # assert(inventory.occupied_space == 1.0)
    # item.queue_free()
    # yield(inventory, "contents_changed")
    # assert(inventory.occupied_space == 0.0)
    pass


func test_stack_split_join() -> void:
    assert(inventory.add_item(stackable_item))
    assert(inventory.split(stackable_item, 5) != null)
    assert(inventory.get_items().size() == 2)
    var item1 = inventory.get_items()[0]
    var item2 = inventory.get_items()[1]
    assert(item1.get_property(InventoryStacked.KEY_STACK_SIZE) == 5)
    assert(item2.get_property(InventoryStacked.KEY_STACK_SIZE) == 5)
    assert(inventory.join(item1, item2))
    assert(item1.get_property(InventoryStacked.KEY_STACK_SIZE) == 10)
    assert(inventory.get_items().size() == 1)


func test_serialize() -> void:
    assert(inventory.add_item(item))
    var inventory_data = inventory.serialize()
    var capacity = inventory.capacity
    var occupied_space = inventory.occupied_space
    inventory.reset()
    assert(inventory.get_items().empty())
    assert(inventory.capacity == 0)
    assert(inventory.occupied_space == 0)
    assert(inventory.deserialize(inventory_data))
    assert(inventory.get_items().size() == 1)
    assert(inventory.capacity == capacity)
    assert(inventory.occupied_space == occupied_space)

