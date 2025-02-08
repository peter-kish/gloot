extends TestSuite

var inventory: Inventory
var inventory_2: Inventory
var item: InventoryItem
var big_item: InventoryItem
var stackable_item: InventoryItem
var stackable_item_2: InventoryItem
var limited_stackable_item: InventoryItem
var limited_stackable_item_2: InventoryItem

const TEST_PROTOSET = preload("res://tests/data/protoset_stacks.json")


func init_suite() -> void:
    tests = [
        "test_space",
        "test_big_item",
        "test_change_capacity",
        "test_invalid_capacity",
        "test_stack_split_join",
        "test_automerge",
        "test_automerge_custom_dst_properties",
        "test_automerge_custom_src_properties",
        "test_max_stack_size",
        "test_automerge_max_stack_size",
        "test_add_item",
        "test_add_item_autosplitmerge",
        "test_add_item_autosplitmerge_limited_capacity",
        "test_add_item_autosplitmerge_limited_capacity_with_item",
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


func test_space() -> void:
    assert(inventory.get_constraint(WeightConstraint).capacity == 10.0)
    assert(inventory.get_constraint(WeightConstraint).get_free_space() == 10.0)
    assert(inventory.get_constraint(WeightConstraint).get_occupied_space() == 0.0)
    assert(inventory.can_add_item(item))
    assert(inventory.add_item(item))
    assert(inventory.get_constraint(WeightConstraint).get_occupied_space() == 1.0)
    assert(inventory.get_constraint(WeightConstraint).get_free_space() == 9.0)


func test_big_item() -> void:
    assert(!inventory.can_add_item(big_item))
    assert(!inventory.add_item(big_item))


func test_change_capacity() -> void:
    inventory.get_constraint(WeightConstraint).capacity = 0.5
    assert(!inventory.can_add_item(item))
    assert(!inventory.add_item(item))


func test_invalid_capacity() -> void:
    inventory.get_constraint(WeightConstraint).capacity = 21
    assert(inventory.add_item(big_item))
    inventory.get_constraint(WeightConstraint).capacity = 19
    assert(inventory.get_constraint(WeightConstraint).capacity == 21)


func test_stack_split_join() -> void:
    assert(inventory.add_item(stackable_item))
    assert(inventory.split_stack(stackable_item, 5) != null)
    assert(inventory.get_item_count() == 2)
    var item1 = inventory.get_items()[0]
    var item2 = inventory.get_items()[1]
    assert(item1.get_stack_size() == 5)
    assert(item2.get_stack_size() == 5)
    var joined = item2.merge_into(item1)
    assert(joined)
    assert(item1.get_stack_size() == 10)
    assert(inventory.get_item_count() == 1)


func test_automerge() -> void:
    assert(stackable_item.set_stack_size(2))
    assert(stackable_item_2.set_stack_size(2))
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(is_node_valid(stackable_item))
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 1)
    
    
func test_automerge_custom_dst_properties() -> void:
    assert(stackable_item.set_stack_size(2))
    assert(stackable_item_2.set_stack_size(2))
    stackable_item_2.set_property("custom_property", "custom_value")
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(inventory.has_item(stackable_item))
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 2)
    assert(inventory.has_item(stackable_item_2))


func test_automerge_custom_src_properties() -> void:
    assert(stackable_item.set_stack_size(2))
    stackable_item.set_property("custom_property", "custom_value")
    assert(stackable_item_2.set_stack_size(2))
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(inventory.has_item(stackable_item))
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 2)
    assert(inventory.has_item(stackable_item_2))


func test_max_stack_size() -> void:
    assert(limited_stackable_item.set_stack_size(3))
    assert(inventory.add_item(limited_stackable_item))
    assert(limited_stackable_item.get_stack_size() == 3)
    assert(inventory.add_item_autosplitmerge(limited_stackable_item_2))
    assert(limited_stackable_item.get_stack_size() == 5)
    assert(limited_stackable_item_2.get_stack_size() == 3)


func test_automerge_max_stack_size() -> void:
    assert(stackable_item.set_stack_size(2))
    stackable_item.set_max_stack_size(3)
    assert(stackable_item_2.set_stack_size(2))
    assert(inventory.add_item_automerge(stackable_item))
    assert(inventory.get_item_count() == 1)
    assert(inventory.add_item_automerge(stackable_item_2))
    assert(inventory.get_item_count() == 2)
    assert(stackable_item.get_stack_size() == 3)
    assert(stackable_item_2.get_stack_size() == 1)


func test_add_item() -> void:
    assert(inventory.add_item(limited_stackable_item))
    assert(inventory_2.add_item(limited_stackable_item_2))
    assert(inventory_2.add_item(limited_stackable_item))
    assert(!inventory.has_item(limited_stackable_item))
    assert(inventory_2.has_item(limited_stackable_item))
    assert(inventory_2.has_item(limited_stackable_item_2))


func test_add_item_autosplitmerge() -> void:
    assert(stackable_item.set_stack_size(7))
    assert(stackable_item_2.set_stack_size(5))
    assert(inventory.add_item(stackable_item))
    assert(inventory_2.add_item(stackable_item_2))
    assert(inventory.add_item_autosplitmerge(stackable_item_2))
    assert(stackable_item.get_stack_size() == 10)
    assert(stackable_item_2.get_stack_size() == 2)
    assert(inventory.get_item_count() == 1)
    assert(inventory.get_constraint(WeightConstraint).get_occupied_space() == 10)
    assert(inventory_2.get_item_count() == 1)


func test_add_item_autosplitmerge_limited_capacity() -> void:
    inventory.get_constraint(WeightConstraint).capacity = 9
    assert(inventory.add_item_autosplitmerge(stackable_item))
    assert(stackable_item.get_stack_size() == 1)


func test_add_item_autosplitmerge_limited_capacity_with_item() -> void:
    inventory.get_constraint(WeightConstraint).capacity = 5
    assert(stackable_item.set_stack_size(2))

    assert(inventory.add_item(stackable_item))

    assert(inventory.add_item_autosplitmerge(stackable_item_2))
    assert(stackable_item_2.get_stack_size() == 7)


func test_serialize() -> void:
    assert(inventory.add_item(item))
    var inventory_data = inventory.serialize()
    var capacity = inventory.get_constraint(WeightConstraint).capacity
    var occupied_space = inventory.get_constraint(WeightConstraint).get_occupied_space()
    inventory.reset()
    assert(inventory.get_items().is_empty())
    assert(inventory.deserialize(inventory_data))
    assert(inventory.get_item_count() == 1)
    assert(inventory.get_constraint(WeightConstraint).capacity == capacity)
    assert(inventory.get_constraint(WeightConstraint).get_occupied_space() == occupied_space)
    

func test_serialize_json() -> void:
    assert(inventory.add_item(item))
    var inventory_data = inventory.serialize()
    var capacity = inventory.get_constraint(WeightConstraint).capacity
    var occupied_space = inventory.get_constraint(WeightConstraint).get_occupied_space()

    # To and from JSON serialization
    var json_string: String = JSON.stringify(inventory_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    inventory_data = test_json_conv.data

    inventory.reset()
    assert(inventory.get_items().is_empty())
    assert(inventory.deserialize(inventory_data))
    assert(inventory.get_item_count() == 1)
    assert(inventory.get_constraint(WeightConstraint).capacity == capacity)
    assert(inventory.get_constraint(WeightConstraint).get_occupied_space() == occupied_space)
