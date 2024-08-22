extends TestSuite

const ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")
const ItemCount = preload("res://addons/gloot/core/item_count.gd")

var inventory: Inventory
var inventory2: Inventory
var constraint_manager: ConstraintManager

const TEST_PROTOSET = preload("res://tests/data/protoset_basic.json")
const TEST_PROTOTYPE_ID = "minimal_item"
const TEST_PROTOSET_W = preload("res://tests/data/protoset_stacks.json")
const TEST_PROTOTYPE_ID_W = "minimal_item"
const TEST_PROTOSET_G = preload("res://tests/data/protoset_grid.json")
const TEST_PROTOTYPE_ID_G = "item_2x2"


func init_suite():
    tests = [
        "test_init",
        "test_has_space_for",
        "test_w_has_space_for",
        "test_g_has_space_for",
        "test_wg_has_space_for",
        "test_g_enforce_constraints",
        "test_sg_enforce_constraints",
        "test_sg_wrong_stack_type",
        "test_wg_enforce_constraints",
    ]


func init_test() -> void:
    inventory = create_inventory(TEST_PROTOSET)
    inventory2 = create_inventory(TEST_PROTOSET)
    constraint_manager = inventory._constraint_manager


func cleanup_test() -> void:
    free_inventory(inventory)
    free_inventory(inventory2)


func test_init() -> void:
    assert(constraint_manager.get_constraint(WeightConstraint) == null)
    assert(constraint_manager.get_constraint(GridConstraint) == null)
    assert(constraint_manager.inventory == inventory)


func test_has_space_for() -> void:
    var item = create_item(TEST_PROTOSET, TEST_PROTOTYPE_ID)
    assert(constraint_manager.has_space_for(item))


func test_w_has_space_for() -> void:
    inventory.protoset = TEST_PROTOSET_W
    var item = create_item(TEST_PROTOSET_W, TEST_PROTOTYPE_ID_W)

    enable_weight_constraint(inventory, 10.0)
    assert(constraint_manager.get_constraint(WeightConstraint) != null)

    var test_data := [
        {input = 1.0, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = 10.0, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = 11.0, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        WeightConstraint.set_item_weight(item, data.input)
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_g_has_space_for() -> void:
    inventory.protoset = TEST_PROTOSET_G
    var item = create_item(TEST_PROTOSET_G, TEST_PROTOTYPE_ID_G)

    var grid_constraint = enable_grid_constraint(inventory, Vector2i(3, 3))
    assert(grid_constraint != null)

    var test_data := [
        {input = Vector2i(1, 1), expected = {has_space = true, space = ItemCount.new(9)}},
        {input = Vector2i(2, 2), expected = {has_space = true, space = ItemCount.new(1)}},
        {input = Vector2i(3, 3), expected = {has_space = true, space = ItemCount.new(1)}},
        {input = Vector2i(4, 4), expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        assert(grid_constraint.set_item_size(item, data.input))
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_wg_has_space_for() -> void:
    inventory.protoset = TEST_PROTOSET_W
    var item = create_item(TEST_PROTOSET_W, TEST_PROTOTYPE_ID_W)

    enable_grid_constraint(inventory, Vector2i(3, 3))
    enable_weight_constraint(inventory, 10.0)
    var grid_constraint = constraint_manager.get_constraint(GridConstraint)
    var weight_constraint = constraint_manager.get_constraint(WeightConstraint)
    assert(grid_constraint != null)
    assert(weight_constraint != null)

    var test_data := [
        {input = {weight = 1.0, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {weight = 10.0, size = Vector2i(3, 3)}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 11.0, size = Vector2i.ONE}, expected = {has_space = false, space = ItemCount.zero()}},
        {input = {weight = 1.0, size = Vector2i(4, 4)}, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        WeightConstraint.set_item_weight(item, data.input.weight)
        assert(grid_constraint.set_item_size(item, data.input.size))
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_g_enforce_constraints() -> void:
    inventory.protoset = TEST_PROTOSET_G
    var item = create_item(TEST_PROTOSET_G, TEST_PROTOTYPE_ID_G)

    var grid_constraint = enable_grid_constraint(inventory, Vector2i(3, 3))
    assert(grid_constraint != null)

    var new_item = inventory.create_and_add_item("item_2x2")
    assert(grid_constraint.get_item_position(new_item) == Vector2i.ZERO)

    var test_data := [
        {input = Rect2i(0, 0, 2, 2), expected = false},
        {input = Rect2i(0, 0, 1, 1), expected = true},
    ]

    for data in test_data:
        grid_constraint.set_item_rect(new_item, data.input)
        var add_item_result := inventory.add_item(item)
        assert(add_item_result == data.expected)
        if add_item_result:
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(item), item))

    inventory.remove_item(new_item)


func test_sg_enforce_constraints() -> void:
    inventory.protoset = TEST_PROTOSET_G

    var grid_constraint := enable_grid_constraint(inventory, Vector2i(3, 3))
    assert(grid_constraint != null)

    var new_item := inventory.create_and_add_item(TEST_PROTOTYPE_ID_G)
    assert(grid_constraint.get_item_position(new_item) == Vector2i.ZERO)

    # Test cases:
    # 1. Grid space available and stack space available
    # 2. No grid space available, but stack space available
    # 3. Grid space available, but no stack space available
    # 4. No grid space available and no stack space available
    var test_data := [
        {input = {inv_size = Vector2i(4, 4), new_item_stack_size = 1, new_item_max_stack_size = 2}, expected = true},
        {input = {inv_size = Vector2i(3, 3), new_item_stack_size = 1, new_item_max_stack_size = 2}, expected = true},
        {input = {inv_size = Vector2i(4, 4), new_item_stack_size = 1, new_item_max_stack_size = 1}, expected = true},
        {input = {inv_size = Vector2i(3, 3), new_item_stack_size = 1, new_item_max_stack_size = 1}, expected = false},
    ]

    for data in test_data:
        var test_item := InventoryItem.new(TEST_PROTOSET_G, TEST_PROTOTYPE_ID_G)

        grid_constraint.size = data.input.inv_size
        new_item.set_max_stack_size(data.input.new_item_max_stack_size)
        assert(new_item.set_stack_size(data.input.new_item_stack_size))
        var add_item_result := inventory.add_item(test_item)
        assert(add_item_result == data.expected)
        if add_item_result && (test_item.get_stack_size() > 0):
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(test_item), test_item))

        inventory.remove_item(test_item)

    inventory.remove_item(new_item)


func test_sg_wrong_stack_type() -> void:
    inventory.protoset = TEST_PROTOSET_G

    var grid_constraint := enable_grid_constraint(inventory, Vector2i(2, 2))
    assert(grid_constraint != null)

    var new_item := inventory.create_and_add_item(TEST_PROTOTYPE_ID_G)
    assert(grid_constraint.get_item_position(new_item) == Vector2i.ZERO)

    var test_item := InventoryItem.new(TEST_PROTOSET_G, "item_1x1")
    new_item.set_max_stack_size(2)
    assert(new_item.set_stack_size(1))
    assert(!inventory.can_add_item(test_item))
    assert(!inventory.add_item(test_item))

    inventory.remove_item(test_item)
    inventory.remove_item(new_item)


func test_wg_enforce_constraints() -> void:
    inventory.protoset = TEST_PROTOSET_G
    var item = create_item(TEST_PROTOSET_G, TEST_PROTOTYPE_ID_G)

    var weight_constraint = enable_weight_constraint(inventory, 10.0)
    var grid_constraint = enable_grid_constraint(inventory, Vector2i(3, 3))
    assert(weight_constraint != null)
    assert(grid_constraint != null)

    var new_item = inventory.create_and_add_item("item_1x1")
    assert(grid_constraint.get_item_position(new_item) == Vector2i.ZERO)

    var test_data := [
        {input = {new_item_rect = Rect2i(0, 0, 2, 2), item_weight = 1.0}, expected = false},
        {input = {new_item_rect = Rect2i(0, 0, 1, 1), item_weight = 11.0}, expected = false},
        {input = {new_item_rect = Rect2i(0, 0, 1, 1), item_weight = 1.0}, expected = true},
    ]

    for data in test_data:
        grid_constraint.set_item_rect(new_item, data.input.new_item_rect)
        WeightConstraint.set_item_weight(item, data.input.item_weight)
        var add_item_result := inventory.add_item(item)
        assert(add_item_result == data.expected)
        if add_item_result && (item.get_stack_size() > 0):
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(item), item))
        
    inventory.remove_item(new_item)
