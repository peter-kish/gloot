extends TestSuite

var inventory: Inventory
var item: InventoryItem
var item_count_constraint: ItemCountConstraint

const TEST_PROTOSET = preload("res://tests/data/protoset_basic.json")


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
    item = create_item(TEST_PROTOSET, "minimal_item")
    inventory = create_inventory(TEST_PROTOSET)
    item_count_constraint = enable_item_count_constraint(inventory)


func cleanup_test() -> void:
    free_inventory(inventory)


func test_init() -> void:
    assert(item_count_constraint.inventory == inventory)
    assert(item_count_constraint.get_occupied_space() == 0)


func test_capacity() -> void:
    item_count_constraint.capacity = 10
    assert(item_count_constraint.capacity == 10)
    item_count_constraint.capacity = -10
    assert(item_count_constraint.capacity == 1)


func test_occupied_space() -> void:
    inventory.add_item(item)
    assert(item_count_constraint.get_occupied_space() == 1)
    inventory.remove_item(item)
    assert(item_count_constraint.get_occupied_space() == 0)


func test_get_free_space() -> void:
    assert(item_count_constraint.get_free_space() == 1)
    item_count_constraint.capacity = 10
    assert(item_count_constraint.get_free_space() == 10)
    item_count_constraint.capacity = 100
    inventory.add_item(item)
    assert(item_count_constraint.get_free_space() == 99)


func test_get_space_for() -> void:
    assert(item_count_constraint.get_space_for(item) == 1)

    item_count_constraint.capacity = 10
    assert(item_count_constraint.get_space_for(item) == 10)

    item_count_constraint.capacity = 20
    assert(item_count_constraint.get_space_for(item) == 20)

    inventory.add_item(item)
    assert(item_count_constraint.get_space_for(item) == 19)


func test_swap_items() -> void:
    item_count_constraint.capacity = 3
    var item1 = inventory.create_and_add_item("minimal_item")
    
    var inv2 = Inventory.new()
    inv2.protoset = TEST_PROTOSET
    enable_item_count_constraint(inv2, 20)

    var item2 = inv2.create_and_add_item("minimal_item")

    assert(InventoryItem.swap(item1, item2))
    assert(inventory.has_item(item2))
    assert(!inventory.has_item(item1))

    free_inventory(inv2)


func test_serialize() -> void:
    item_count_constraint.capacity = 42
    var constraint_data = item_count_constraint.serialize()
    var capacity = item_count_constraint.capacity

    item_count_constraint.reset()
    assert(item_count_constraint.capacity == 1)

    assert(item_count_constraint.deserialize(constraint_data))
    assert(item_count_constraint.capacity == capacity)
    

func test_serialize_json() -> void:
    item_count_constraint.capacity = 42
    var constraint_data = item_count_constraint.serialize()
    var capacity = item_count_constraint.capacity

    # To and from JSON serialization
    var json_string: String = JSON.stringify(constraint_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    constraint_data = test_json_conv.data

    item_count_constraint.reset()
    assert(item_count_constraint.capacity == 1)
    
    assert(item_count_constraint.deserialize(constraint_data))
    assert(item_count_constraint.capacity == capacity)
