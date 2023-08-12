extends TestSuite

const WeightConstraint = preload("res://addons/gloot/core/constraints/weight_constraint.gd")

var inventory: Inventory
var item: InventoryItem
var weight_constraint: WeightConstraint

const TEST_PROTOSET = preload("res://tests/data/item_definitions_stack.tres")


func init_suite():
    tests = [
        "test_init",
        "test_capacity",
        "test_occupied_space",
        "test_get_free_space",
        "test_get_space_for",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOSET, "big_item")
    inventory = create_inventory(TEST_PROTOSET)
    inventory._constraint_manager.enable_weight_constraint_()
    weight_constraint = inventory._constraint_manager.get_weight_constraint()


func cleanup_test() -> void:
    free_inventory(inventory)
    free_item(item)


func test_init() -> void:
    assert(weight_constraint.inventory == inventory)
    assert(weight_constraint.capacity == 0.0)
    assert(weight_constraint.occupied_space == 0.0)


func test_capacity() -> void:
    weight_constraint.capacity = 10.0
    assert(weight_constraint.capacity == 10.0)
    assert(!weight_constraint.has_unlimited_capacity())

    weight_constraint.capacity = -10.0
    assert(weight_constraint.capacity == 0.0)
    assert(weight_constraint.has_unlimited_capacity())


func test_occupied_space() -> void:
    # Check if occupied_space is updated on item_added
    inventory.add_item(item)
    assert(weight_constraint.occupied_space == WeightConstraint.get_item_weight(item))

    # Check if occupied_space is updated on item_modified
    WeightConstraint.set_item_weight(item, 10.0)
    assert(weight_constraint.occupied_space == 10.0)

    # Check if occupied_space is updated on item_removed
    inventory.remove_item(item)
    assert(weight_constraint.occupied_space == 0.0)
    free_item(item)


func test_get_free_space() -> void:
    assert(weight_constraint.get_free_space() == 0.0)
    weight_constraint.capacity = 10.0
    assert(weight_constraint.get_free_space() == 10.0)
    weight_constraint.capacity = 100.0
    inventory.add_item(item)
    assert(weight_constraint.get_free_space() == 80.0)


func test_get_space_for() -> void:
    assert(weight_constraint.get_space_for(item).is_inf())

    weight_constraint.capacity = 10.0
    assert(!weight_constraint.get_space_for(item).is_inf())
    assert(weight_constraint.get_space_for(item).count == 0)

    weight_constraint.capacity = 20.0
    assert(!weight_constraint.get_space_for(item).is_inf())
    assert(weight_constraint.get_space_for(item).count == 1)

    weight_constraint.capacity = 40.0
    assert(!weight_constraint.get_space_for(item).is_inf())
    assert(weight_constraint.get_space_for(item).count == 2)

    inventory.add_item(item)
    assert(!weight_constraint.get_space_for(item).is_inf())
    assert(weight_constraint.get_space_for(item).count == 1)


func test_serialize() -> void:
    weight_constraint.capacity = 42.42
    var constraint_data = weight_constraint.serialize()
    var capacity = weight_constraint.capacity

    weight_constraint.reset()
    assert(weight_constraint.capacity == 0)

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
    assert(weight_constraint.capacity == 0)
    
    assert(weight_constraint.deserialize(constraint_data))
    assert(weight_constraint.capacity == capacity)
