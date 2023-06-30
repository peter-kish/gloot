extends TestSuite

var inventory: Inventory
var item: InventoryItem
var weight_component: WeightComponent

const TEST_PROTOSET = preload("res://tests/data/item_definitions_stack.tres")


func init_suite():
    tests = [
        "test_init",
        "test_capacity",
        "test_occupied_space",
        "test_get_free_space",
        "test_get_space_for",
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOSET, "big_item")
    inventory = create_inventory(TEST_PROTOSET)
    weight_component = WeightComponent.new()
    weight_component.inventory = inventory


func cleanup_test() -> void:
    free_inventory(inventory)
    free_item(item)


func test_init() -> void:
    assert(weight_component.inventory == inventory)
    assert(weight_component.capacity == 0.0)
    assert(weight_component.occupied_space == 0.0)


func test_capacity() -> void:
    weight_component.capacity = 10.0
    assert(weight_component.capacity == 10.0)
    assert(!weight_component.has_unlimited_capacity())

    weight_component.capacity = -10.0
    assert(weight_component.capacity == 0.0)
    assert(weight_component.has_unlimited_capacity())


func test_occupied_space() -> void:
    # Check if occupied_space is updated on item_added
    inventory.add_item(item)
    assert(weight_component.occupied_space == WeightComponent.get_item_weight(item))

    # Check if occupied_space is updated on item_modified
    WeightComponent.set_item_weight(item, 10.0)
    assert(weight_component.occupied_space == 10.0)

    # Check if occupied_space is updated on item_removed
    inventory.remove_item(item)
    assert(weight_component.occupied_space == 0.0)
    free_item(item)


func test_get_free_space() -> void:
    assert(weight_component.get_free_space() == 0.0)
    weight_component.capacity = 10.0
    assert(weight_component.get_free_space() == 10.0)
    weight_component.capacity = 100.0
    inventory.add_item(item)
    assert(weight_component.get_free_space() == 80.0)


func test_get_space_for() -> void:
    assert(weight_component.get_space_for(item).is_inf())

    weight_component.capacity = 10.0
    assert(!weight_component.get_space_for(item).is_inf())
    assert(weight_component.get_space_for(item).count == 0)

    weight_component.capacity = 20.0
    assert(!weight_component.get_space_for(item).is_inf())
    assert(weight_component.get_space_for(item).count == 1)

    weight_component.capacity = 40.0
    assert(!weight_component.get_space_for(item).is_inf())
    assert(weight_component.get_space_for(item).count == 2)

    inventory.add_item(item)
    assert(!weight_component.get_space_for(item).is_inf())
    assert(weight_component.get_space_for(item).count == 1)
