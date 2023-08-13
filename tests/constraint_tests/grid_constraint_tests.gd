extends TestSuite

const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

var inventory: Inventory
var item: InventoryItem
var grid_constraint: GridConstraint

const TEST_PROTOSET = preload("res://tests/data/item_definitions_grid.tres")
const TEST_PROTOTYPE = "item_2x2"


func init_suite():
    tests = [
        "test_set_size",
        "test_item_position",
        "test_item_size",
        "test_item_rect",
        "test_add_item_at",
        "test_create_and_add_item_at",
        "test_get_items_under",
        "test_move_item_to",
        "test_transfer_to",
        "test_rect_free",
        "test_sort",
        "test_get_space_for",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOSET, TEST_PROTOTYPE)
    inventory = create_inventory(TEST_PROTOSET)
    inventory._constraint_manager.enable_grid_constraint()
    grid_constraint = inventory._constraint_manager.get_grid_constraint()


func cleanup_test() -> void:
    free_item(item)
    free_inventory(inventory)


func test_set_size() -> void:
    assert(grid_constraint.size == Vector2i(10, 10))

    grid_constraint.size = Vector2i(3, 3)
    assert(grid_constraint.size == Vector2i(3, 3))


func test_item_position() -> void:
    assert(grid_constraint.get_item_position(item) == Vector2i.ZERO)
    assert(inventory.add_item(item))

    var test_data := [
        {input = Vector2i(9, 9), expected = {return_value = false, position = Vector2i.ZERO}},
        {input = Vector2i(-1, -1), expected = {return_value = false, position = Vector2i.ZERO}},
        {input = Vector2i(8, 8), expected = {return_value = true, position = Vector2i(8, 8)}},
    ]

    for data in test_data:
        assert(grid_constraint.set_item_position(item, data.input) == data.expected.return_value)
        assert(grid_constraint.get_item_position(item) == data.expected.position)


func test_item_size() -> void:
    assert(grid_constraint.get_item_size(item) == Vector2i(2, 2))
    assert(inventory.add_item(item))

    var test_data := [
        {input = Vector2i(-1, -1), expected = {return_value = false, size = Vector2i(2, 2)}},
        {input = Vector2i(4, 4), expected = {return_value = true, size = Vector2i(4, 4)}},
        {input = Vector2i(15, 15), expected = {return_value = false, size = Vector2i(4, 4)}},
    ]

    for data in test_data:
        assert(grid_constraint.set_item_size(item, data.input) == data.expected.return_value)
        assert(grid_constraint.get_item_size(item) == data.expected.size)


func test_item_rect() -> void:
    assert(grid_constraint.get_item_rect(item) == Rect2i(0, 0, 2, 2))
    assert(inventory.add_item(item))

    var test_data := [
        {input = Rect2i(0, 0, -1, -1), expected = {return_value = false, rect = Rect2i(0, 0, 2, 2)}},
        {input = Rect2i(4, 4, 4, 4), expected = {return_value = true, rect = Rect2i(4, 4, 4, 4)}},
        {input = Rect2i(9, 9, 4, 4), expected = {return_value = false, rect = Rect2i(4, 4, 4, 4)}},
    ]

    for data in test_data:
        assert(grid_constraint.set_item_rect(item, data.input) == data.expected.return_value)
        assert(grid_constraint.get_item_rect(item) == data.expected.rect)


func test_add_item_at() -> void:
    var test_data := [
        {input = Vector2i.ZERO, expected = {return_value = true, has_item = true, position = Vector2i.ZERO}},
        {input = Vector2i(4, 4), expected = {return_value = true, has_item = true, position = Vector2i(4, 4)}},
        {input = Vector2i(15, 15), expected = {return_value = false, has_item = false, position = Vector2i(4, 4)}},
    ]

    for data in test_data:
        assert(grid_constraint.add_item_at(item, data.input) == data.expected.return_value)
        assert(inventory.has_item(item) == data.expected.has_item)
        assert(grid_constraint.get_item_position(item) == data.expected.position)

        if inventory.has_item(item):
            inventory.remove_item(item)


func test_create_and_add_item_at() -> void:
    var test_data := [
        {input = Vector2i.ZERO, expected = {return_value = true, has_item = true, position = Vector2i.ZERO}},
        {input = Vector2i(4, 4), expected = {return_value = true, has_item = true, position = Vector2i(4, 4)}},
        {input = Vector2i(15, 15), expected = {return_value = false, has_item = false, position = Vector2i.ZERO}},
    ]

    for data in test_data:
        var new_item = grid_constraint.create_and_add_item_at(TEST_PROTOTYPE, data.input)
        assert((new_item != null) == data.expected.return_value)
        assert(inventory.has_item(new_item) == data.expected.has_item)
        if (inventory.has_item(new_item)):
            assert(grid_constraint.get_item_position(new_item) == data.expected.position)

        if inventory.has_item(new_item):
            inventory.remove_item(new_item)
        if new_item != null:
            new_item.free()


func test_get_items_under() -> void:
    var test_data := [
        {input = {item_positions = [Vector2i.ZERO], test_rect = Rect2i(0, 0, 1, 1)}, expected = 1},
        {input = {item_positions = [Vector2i.ZERO], test_rect = Rect2i(1, 1, 1, 1)}, expected = 1},
        {input = {item_positions = [Vector2i.ZERO], test_rect = Rect2i(2, 2, 1, 1)}, expected = 0},
        {input = {item_positions = [Vector2i.ZERO, Vector2i(2, 2)], test_rect = Rect2i(1, 1, 2, 2)}, expected = 2},
    ]

    for data in test_data:
        var new_items: Array[InventoryItem] = []
        for item_position in data.input.item_positions:
            var new_item := grid_constraint.create_and_add_item_at(TEST_PROTOTYPE, item_position)
            assert(new_item != null)
            new_items.append(new_item)
        var items := grid_constraint.get_items_under(data.input.test_rect)
        assert(items.size() == data.expected)

        for new_item in new_items:
            inventory.remove_item(new_item)
            new_item.free()


func test_move_item_to() -> void:
    grid_constraint.add_item_at(item, Vector2i(2, 2))

    var test_data := [
        {input = Vector2i(1, 0), expected = true},
        {input = Vector2i(1, 1), expected = false},
        {input = Vector2i(4, 4), expected = true},
        {input = Vector2i(15, 15), expected = false},
    ]

    for data in test_data:
        var new_item = inventory.create_and_add_item(TEST_PROTOTYPE)
        assert(new_item != null)
        assert(grid_constraint.move_item_to(new_item, data.input) == data.expected)
        assert((grid_constraint.get_item_position(new_item) == data.input) == data.expected)

        inventory.remove_item(new_item)
        new_item.free()


func test_transfer_to() -> void:
    var inventory2 := create_inventory(TEST_PROTOSET)
    var grid_constraint2 := GridConstraint.new(inventory2)
    grid_constraint2.create_and_add_item_at(TEST_PROTOTYPE, Vector2i(2, 2))

    inventory.add_item(item)

    var test_data := [
        {input = Vector2i.ZERO, expected = true},
        {input = Vector2i.ONE, expected = false},
        {input = Vector2i(4, 4), expected = true},
        {input = Vector2i(15, 15), expected = false},
    ]

    for data in test_data:
        assert(grid_constraint.transfer_to(item, grid_constraint2, data.input) == data.expected)
        if data.expected:
            assert(inventory2.has_item(item))
            assert(grid_constraint2.get_item_position(item) == data.input)

        if inventory2.has_item(item):
            assert(inventory2.transfer(item, inventory))

    free_inventory(inventory2)


func test_rect_free() -> void:
    grid_constraint.add_item_at(item, Vector2i(2, 2))

    var test_data := [
        {input = {rect = Rect2i(-1, -1, 1, 1), exception = null}, expected = false},
        {input = {rect = Rect2i(0, 0, 1, 1), exception = null}, expected = true},
        {input = {rect = Rect2i(0, 0, 3, 3), exception = null}, expected = false},
        {input = {rect = Rect2i(0, 0, 3, 3), exception = item}, expected = true},
        {input = {rect = Rect2i(4, 4, 1, 1), exception = null}, expected = true},
        {input = {rect = Rect2i(4, 4, 15, 15), exception = null}, expected = false},
    ]
    
    for data in test_data:
        assert(grid_constraint.rect_free(data.input.rect, data.input.exception) == data.expected)


func test_sort() -> void:
    var item1 = grid_constraint.create_and_add_item_at("item_1x1", Vector2i.ZERO)
    var item2 = grid_constraint.create_and_add_item_at("item_1x1", Vector2i(1, 0))
    var item3 = grid_constraint.create_and_add_item_at("item_2x2", Vector2i(0, 1))

    grid_constraint.sort()
    assert(grid_constraint.get_item_position(item3) == Vector2i.ZERO)
    assert(grid_constraint.get_item_position(item1) == Vector2i(0, 2))
    assert(grid_constraint.get_item_position(item2) == Vector2i(0, 3))

    inventory.remove_item(item1)
    inventory.remove_item(item2)
    inventory.remove_item(item3)
    item1.free()
    item2.free()
    item3.free()


func test_get_space_for() -> void:
    # Empty inventory
    var test_data := [
        {input = Vector2i.ONE, expected = ItemCount.zero()},
        {input = Vector2i(2, 2), expected = ItemCount.new(1)},
        {input = Vector2i(3, 3), expected = ItemCount.new(1)},
        {input = Vector2i(4, 4), expected = ItemCount.new(4)},
    ]

    for data in test_data:
        grid_constraint.size = data.input
        assert(grid_constraint.get_space_for(item).eq(data.expected))

    # One item in inventory
    grid_constraint.size = Vector2i(2, 2)
    var item2 = inventory.create_and_add_item(TEST_PROTOTYPE)
    test_data = [
        {input = Vector2i(2, 2), expected = ItemCount.zero()},
        {input = Vector2i(3, 3), expected = ItemCount.zero()},
        {input = Vector2i(4, 4), expected = ItemCount.new(3)},
    ]

    for data in test_data:
        grid_constraint.size = data.input
        assert(grid_constraint.get_space_for(item).eq(data.expected))

    inventory.remove_item(item2)
    free_item(item2)


func test_serialize() -> void:
    grid_constraint.size = Vector2i(4, 2)
    var constraint_data = grid_constraint.serialize()
    var size = grid_constraint.size

    grid_constraint.reset()
    assert(grid_constraint.size == GridConstraint.DEFAULT_SIZE)

    assert(grid_constraint.deserialize(constraint_data))
    assert(grid_constraint.size == size)
    

func test_serialize_json() -> void:
    grid_constraint.size = Vector2i(4, 2)
    var constraint_data = grid_constraint.serialize()
    var size = grid_constraint.size

    # To and from JSON serialization
    var json_string: String = JSON.stringify(constraint_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    constraint_data = test_json_conv.data

    grid_constraint.reset()
    assert(grid_constraint.size == GridConstraint.DEFAULT_SIZE)
    
    assert(grid_constraint.deserialize(constraint_data))
    assert(grid_constraint.size == size)

