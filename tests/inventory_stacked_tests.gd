extends TestSuite

var inventory: InventoryStacked
var inventory_2: InventoryStacked
var item: InventoryItem
var big_item: InventoryItem
var stackable_item: InventoryItem
var stackable_item_2: InventoryItem
var limited_stackable_item: InventoryItem
var limited_stackable_item_2: InventoryItem

const TEST_PROTOSET = preload("res://tests/data/item_definitions_stack.tres")


func init_suite() -> void:
    tests = [
        "test_space",
        "test_big_item",
        "test_change_capacity",
        "test_unlimited_capacity",
        "test_invalid_capacity",
        "test_contents_changed_signal",
        "test_stack_split_join",
        "test_automerge",
        "test_automerge_custom_dst_properties",
        "test_automerge_custom_src_properties",
        "test_max_stack_size",
        "test_automerge_max_stack_size",
        "test_transfer",
        "test_transfer_autosplit",
        "test_transfer_autosplitmerge",
        "test_serialize",
        "test_serialize_json"
    ]


func init_test() -> void:
    inventory = create_inventory_stacked(TEST_PROTOSET, 10)
    inventory_2 = create_inventory_stacked(TEST_PROTOSET, 10)

    item = create_item(TEST_PROTOSET, "minimal_item")
    big_item = create_item(TEST_PROTOSET, "big_item")
    stackable_item = create_item(TEST_PROTOSET, "stackable_item")
    stackable_item_2 = create_item(TEST_PROTOSET, "stackable_item")
    limited_stackable_item = create_item(TEST_PROTOSET, "limited_stackable_item")
    limited_stackable_item_2 = create_item(TEST_PROTOSET, "limited_stackable_item")


func cleanup_test() -> void:
    free_inventory(inventory)
    free_inventory(inventory_2)

    free_item(item)
    free_item(big_item)
    free_item(stackable_item)
    free_item(stackable_item_2)
    free_item(limited_stackable_item)
    free_item(limited_stackable_item_2)


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
    # await inventory.contents_changed
    # assert(inventory.occupied_space == 0.0)
    pass


func test_stack_split_join() -> void:
    assert(inventory.add_item(stackable_item))
    assert(inventory.split(stackable_item, 5) != null)
    assert(inventory.get_item_count() == 2)
    var item1 = inventory.get_items()[0]
    var item2 = inventory.get_items()[1]
    assert(InventoryStacked.get_item_stack_size(item1) == 5)
    assert(InventoryStacked.get_item_stack_size(item2) == 5)
    var joined = inventory.join(item1, item2)
    assert(joined)
    assert(InventoryStacked.get_item_stack_size(item1) == 10)
    assert(inventory.get_item_count() == 1)


func test_automerge() -> void:
    assert(InventoryStacked.set_item_stack_size(stackable_item, 2))
    assert(InventoryStacked.set_item_stack_size(stackable_item_2, 2))
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(is_node_valid(stackable_item))
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 1)
    
    
func test_automerge_custom_dst_properties() -> void:
    assert(InventoryStacked.set_item_stack_size(stackable_item, 2))
    assert(InventoryStacked.set_item_stack_size(stackable_item_2, 2))
    stackable_item_2.set_property("custom_property", "custom_value")
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(inventory.has_item(stackable_item))
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 2)
    assert(inventory.has_item(stackable_item_2))


func test_automerge_custom_src_properties() -> void:
    assert(InventoryStacked.set_item_stack_size(stackable_item, 2))
    stackable_item.set_property("custom_property", "custom_value")
    assert(InventoryStacked.set_item_stack_size(stackable_item_2, 2))
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(inventory.has_item(stackable_item))
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 2)
    assert(inventory.has_item(stackable_item_2))


func test_max_stack_size() -> void:
    assert(InventoryStacked.set_item_stack_size(limited_stackable_item, 3))
    assert(inventory.add_item(limited_stackable_item))
    assert(InventoryStacked.get_item_stack_size(limited_stackable_item) == 3)
    assert(inventory.add_item_automerge(limited_stackable_item_2))
    assert(InventoryStacked.get_item_stack_size(limited_stackable_item) == 5)
    assert(InventoryStacked.get_item_stack_size(limited_stackable_item_2) == 3)


func test_automerge_max_stack_size() -> void:
    assert(InventoryStacked.set_item_stack_size(stackable_item, 2))
    InventoryStacked.set_item_max_stack_size(stackable_item, 3)
    assert(InventoryStacked.set_item_stack_size(stackable_item_2, 2))
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(is_node_valid(stackable_item))
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 2)
    assert(InventoryStacked.get_item_stack_size(stackable_item) == 3)
    assert(InventoryStacked.get_item_stack_size(stackable_item_2) == 1)


func test_transfer() -> void:
    assert(inventory.add_item(limited_stackable_item))
    assert(inventory_2.add_item(limited_stackable_item_2))
    assert(inventory.transfer(limited_stackable_item, inventory_2))
    assert(!inventory.has_item(limited_stackable_item))
    assert(inventory_2.has_item(limited_stackable_item))
    assert(inventory_2.has_item(limited_stackable_item_2))


func test_transfer_autosplit() -> void:
    assert(InventoryStacked.set_item_stack_size(stackable_item, 7))
    assert(InventoryStacked.set_item_stack_size(stackable_item_2, 5))
    assert(inventory.add_item(stackable_item))
    assert(inventory_2.add_item(stackable_item_2))
    assert(inventory_2.transfer_autosplit(stackable_item_2, inventory))
    assert(InventoryStacked.get_item_stack_size(stackable_item) == 7)
    assert(InventoryStacked.get_item_stack_size(stackable_item_2) == 2)
    assert(inventory.get_item_count() == 2)
    assert(inventory.occupied_space == 10)
    assert(inventory_2.get_item_count() == 1)
    assert(inventory_2.occupied_space == 2)


func test_transfer_autosplitmerge() -> void:
    assert(InventoryStacked.set_item_stack_size(stackable_item, 7))
    assert(InventoryStacked.set_item_stack_size(stackable_item_2, 5))
    assert(inventory.add_item(stackable_item))
    assert(inventory_2.add_item(stackable_item_2))
    assert(inventory_2.transfer_autosplitmerge(stackable_item_2, inventory))
    assert(InventoryStacked.get_item_stack_size(stackable_item) == 10)
    assert(InventoryStacked.get_item_stack_size(stackable_item_2) == 2)
    assert(inventory.get_item_count() == 1)
    assert(inventory.occupied_space == 10)
    assert(inventory_2.get_item_count() == 1)


func test_serialize() -> void:
    assert(inventory.add_item(item))
    var inventory_data = inventory.serialize()
    var capacity = inventory.capacity
    var occupied_space = inventory.occupied_space
    inventory.reset()
    assert(inventory.get_items().is_empty())
    assert(inventory.capacity == 0)
    assert(inventory.occupied_space == 0)
    assert(inventory.deserialize(inventory_data))
    assert(inventory.get_item_count() == 1)
    assert(inventory.capacity == capacity)
    assert(inventory.occupied_space == occupied_space)
    

func test_serialize_json() -> void:
    assert(inventory.add_item(item))
    var inventory_data = inventory.serialize()
    var capacity = inventory.capacity
    var occupied_space = inventory.occupied_space

    # To and from JSON serialization
    var json_string: String = JSON.stringify(inventory_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    inventory_data = test_json_conv.data

    inventory.reset()
    assert(inventory.get_items().is_empty())
    assert(inventory.capacity == 0)
    assert(inventory.occupied_space == 0)
    assert(inventory.deserialize(inventory_data))
    assert(inventory.get_item_count() == 1)
    assert(inventory.capacity == capacity)
    assert(inventory.occupied_space == occupied_space)

