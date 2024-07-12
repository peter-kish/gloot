extends TestSuite

var inventory: Inventory
var item: InventoryItem
var weight_constraint: WeightConstraint

const TEST_PROTOSET = preload("res://tests/data/protoset_stacks.json")


func init_suite():
    tests = [
        "test_init",
        "test_capacity",
        "test_occupied_space",
        "test_get_free_space",
        "test_get_space_for",
        "test_swap_items",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOSET, "big_item")
    inventory = create_inventory(TEST_PROTOSET)
    weight_constraint = enable_weight_constraint(inventory)
    weight_constraint.capacity = 100.0


func cleanup_test() -> void:
    free_inventory(inventory)


func test_init() -> void:
    assert(weight_constraint.inventory == inventory)
    assert(weight_constraint.capacity == 100.0)
    assert(weight_constraint.get_occupied_space() == 0.0)


func test_capacity() -> void:
    weight_constraint.capacity = 10.0
    assert(weight_constraint.capacity == 10.0)
    weight_constraint.capacity = -10.0
    assert(weight_constraint.capacity == 0.0)


func test_occupied_space() -> void:
    # Check if occupied_space is updated on item_added
    inventory.add_item(item)
    assert(weight_constraint.get_occupied_space() == WeightConstraint.get_item_weight(item))

    # Check if occupied_space is updated on item_property_changed
    WeightConstraint.set_item_weight(item, 10.0)
    assert(weight_constraint.get_occupied_space() == 10.0)

    # Check if occupied_space is updated on item_removed
    inventory.remove_item(item)
    assert(weight_constraint.get_occupied_space() == 0.0)


func test_get_free_space() -> void:
    assert(weight_constraint.get_free_space() == 100.0)
    weight_constraint.capacity = 10.0
    assert(weight_constraint.get_free_space() == 10.0)
    weight_constraint.capacity = 100.0
    inventory.add_item(item)
    assert(weight_constraint.get_free_space() == 80.0)


func test_get_space_for() -> void:
    assert(weight_constraint.get_space_for(item) == 5)

    weight_constraint.capacity = 10.0
    assert(weight_constraint.get_space_for(item) == 0)

    weight_constraint.capacity = 20.0
    assert(weight_constraint.get_space_for(item) == 1)

    weight_constraint.capacity = 40.0
    assert(weight_constraint.get_space_for(item) == 2)

    inventory.add_item(item)
    assert(weight_constraint.get_space_for(item) == 1)


func test_swap_items() -> void:
    weight_constraint.capacity = 3
    var small_item = inventory.create_and_add_item("minimal_item")
    
    var inv2 = Inventory.new()
    inv2.protoset = TEST_PROTOSET
    enable_weight_constraint(inv2, 20.0)

    var big_item = inv2.create_and_add_item("big_item")

    assert(!InventoryItem.swap(small_item, big_item))
    WeightConstraint.set_item_weight(big_item, 1)
    assert(InventoryItem.swap(small_item, big_item))
    assert(inventory.has_item(big_item))
    assert(!inventory.has_item(small_item))

    free_inventory(inv2)


func test_serialize() -> void:
    weight_constraint.capacity = 42.42
    var constraint_data = weight_constraint.serialize()
    var capacity = weight_constraint.capacity

    weight_constraint.reset()
    assert(weight_constraint.capacity == WeightConstraint.DEFAULT_CAPACITY)

    assert(weight_constraint.deserialize(constraint_data))
    assert(weight_constraint.capacity == capacity)
    

func test_serialize_json() -> void:
    weight_constraint.capacity = 42.42
    var constraint_data = weight_constraint.serialize()
    var capacity = weight_constraint.capacity

    # To and from JSON serialization
    var json_string: String = JSON.stringify(constraint_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    constraint_data = test_json_conv.data

    weight_constraint.reset()
    assert(weight_constraint.capacity == WeightConstraint.DEFAULT_CAPACITY)
    
    assert(weight_constraint.deserialize(constraint_data))
    assert(weight_constraint.capacity == capacity)
