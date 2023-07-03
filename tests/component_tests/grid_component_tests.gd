extends TestSuite

var inventory: Inventory
var item: InventoryItem
var grid_component: GridComponent

const TEST_PROTOSET = preload("res://tests/data/item_definitions_grid.tres")


func init_suite():
    tests = [
        "test_set_size",
        "test_item_position",
        "test_item_size",
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOSET, "item_2x2")
    inventory = create_inventory(TEST_PROTOSET)
    grid_component = GridComponent.new()
    grid_component.inventory = inventory


func cleanup_test() -> void:
    free_item(item)
    free_inventory(inventory)


func test_set_size() -> void:
    assert(grid_component.size == Vector2i(10, 10))

    grid_component.size = Vector2i(3, 3)
    assert(grid_component.size == Vector2i(3, 3))


func test_item_position() -> void:
    assert(grid_component.get_item_position(item) == Vector2i.ZERO)

    var test_data = [
        {input = Vector2i(9, 9), expected = {return_value = false, position = Vector2i.ZERO}},
        {input = Vector2i(-1, -1), expected = {return_value = false, position = Vector2i.ZERO}},
        {input = Vector2i(8, 8), expected = {return_value = true, position = Vector2i(8, 8)}},
    ]

    for data in test_data:
        assert(grid_component.set_item_position(item, data.input) == data.expected.return_value)
        assert(grid_component.get_item_position(item) == data.expected.position)


func test_item_size() -> void:
    assert(grid_component.get_item_size(item) == Vector2i(2, 2))

    var test_data = [
        {input = Vector2i(-1, -1), expected = {return_value = false, size = Vector2i(2, 2)}},
        {input = Vector2i(4, 4), expected = {return_value = true, size = Vector2i(4, 4)}},
        {input = Vector2i(15, 15), expected = {return_value = false, size = Vector2i(4, 4)}},
    ]

    for data in test_data:
        assert(grid_component.set_item_size(item, data.input) == data.expected.return_value)
        assert(grid_component.get_item_size(item) == data.expected.size)
