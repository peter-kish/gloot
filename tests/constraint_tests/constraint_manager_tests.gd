extends TestSuite

const ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")
const WeightConstraint = preload("res://addons/gloot/core/constraints/weight_constraint.gd")
const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

var inventory: Inventory
var inventory2: Inventory
var item: InventoryItem
var constraint_manager: ConstraintManager

const TEST_PROTOSET = preload("res://tests/data/item_definitions_basic.tres")
const TEST_PROTOTYPE = "minimal_item"
const TEST_PROTOSET_WS = preload("res://tests/data/item_definitions_stack.tres")
const TEST_PROTOTYPE_WS = "minimal_item"
const TEST_PROTOSET_G = preload("res://tests/data/item_definitions_grid.tres")
const TEST_PROTOTYPE_G = "item_2x2"


func init_suite():
    tests = [
        "test_init",
        "test_has_space_for",
        "test_w_has_space_for",
        "test_s_has_space_for",
        "test_g_has_space_for",
        "test_ws_has_space_for",
        "test_wg_has_space_for",
        "test_sg_has_space_for",
        "test_wsg_has_space_for",
        "test_g_enforce_constraints",
        "test_wg_enforce_constraints",
        "test_sg_enforce_constraints",
        "test_wsg_enforce_constraints",
        "test_ws_transfer_autosplit",
        "test_sg_transfer_autosplit",
        "test_wsg_transfer_autosplit",
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOSET, TEST_PROTOTYPE)
    inventory = create_inventory(TEST_PROTOSET)
    inventory2 = create_inventory(TEST_PROTOSET)
    constraint_manager = inventory._constraint_manager


func cleanup_test() -> void:
    free_item(item)
    free_inventory(inventory)
    free_inventory(inventory2)


func test_init() -> void:
    assert(constraint_manager.get_weight_constraint() == null)
    assert(constraint_manager.get_stacks_constraint() == null)
    assert(constraint_manager.get_grid_constraint() == null)
    assert(constraint_manager.inventory == inventory)


func test_has_space_for() -> void:
    assert(constraint_manager.has_space_for(item))


func test_w_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    constraint_manager.enable_weight_constraint_(10.0)
    assert(constraint_manager.get_weight_constraint() != null)

    var test_data := [
        {input = 1.0, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = 10.0, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = 11.0, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        WeightConstraint.set_item_weight(item, data.input)
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_s_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    constraint_manager.enable_stacks_constraint_()
    assert(constraint_manager.get_stacks_constraint() != null)

    var test_data := [
        {input = 1, expected = {has_space = true, space = ItemCount.inf()}},
        {input = 11, expected = {has_space = true, space = ItemCount.inf()}},
        {input = 111, expected = {has_space = true, space = ItemCount.inf()}},
        {input = 1111, expected = {has_space = true, space = ItemCount.inf()}},
    ]

    for data in test_data:
        StacksConstraint.set_item_max_stack_size(item, data.input)
        assert(StacksConstraint.set_item_stack_size(item, data.input))
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_g_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_G
    item.protoset = TEST_PROTOSET_G
    item.prototype_id = TEST_PROTOTYPE_G

    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var grid_constraint = constraint_manager.get_grid_constraint()
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


func test_ws_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    constraint_manager.enable_weight_constraint_(10.0)
    constraint_manager.enable_stacks_constraint_()
    var weight_constraint = constraint_manager.get_weight_constraint()
    var stacks_constraint = constraint_manager.get_stacks_constraint()
    assert(weight_constraint != null)
    assert(stacks_constraint != null)

    var test_data := [
        {input = {weight = 1.0, stack_size = 1}, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = {weight = 10.0, stack_size = 10}, expected = {has_space = false, space = ItemCount.zero()}},
        {input = {weight = 10.0, stack_size = 1}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 1.0, stack_size = 10}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 11.0, stack_size = 1}, expected = {has_space = false, space = ItemCount.zero()}},
        {input = {weight = 1.0, stack_size = 11}, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        WeightConstraint.set_item_weight(item, data.input.weight)
        StacksConstraint.set_item_max_stack_size(item, data.input.stack_size)
        assert(StacksConstraint.set_item_stack_size(item, data.input.stack_size))
        var space : = constraint_manager.get_space_for(item)
        assert(space.eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_wg_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    constraint_manager.enable_weight_constraint_(10.0)
    var grid_constraint = constraint_manager.get_grid_constraint()
    var weight_constraint = constraint_manager.get_weight_constraint()
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


func test_sg_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    constraint_manager.enable_stacks_constraint_()
    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var stacks_constraint = constraint_manager.get_stacks_constraint()
    var grid_constraint = constraint_manager.get_grid_constraint()
    assert(stacks_constraint != null)
    assert(grid_constraint != null)

    var test_data := [
        {input = {stack_size = 1, max_stack_size = 1, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {stack_size = 1, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(18)}},
        {input = {stack_size = 1, max_stack_size = 2, size = Vector2i(3, 3)}, expected = {has_space = true, space = ItemCount.new(2)}},
        {input = {stack_size = 2, max_stack_size = 2, size = Vector2i(3, 3)}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {stack_size = 2, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {stack_size = 2, max_stack_size = 2, size = Vector2i(4, 4)}, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        assert(grid_constraint.set_item_size(item, data.input.size))
        StacksConstraint.set_item_max_stack_size(item, data.input.max_stack_size)
        assert(StacksConstraint.set_item_stack_size(item, data.input.stack_size))
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_wsg_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    constraint_manager.enable_weight_constraint_(10.0)
    constraint_manager.enable_stacks_constraint_()
    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var weight_constraint = constraint_manager.get_weight_constraint()
    var stacks_constraint = constraint_manager.get_stacks_constraint()
    var grid_constraint = constraint_manager.get_grid_constraint()
    assert(weight_constraint != null)
    assert(stacks_constraint != null)
    assert(grid_constraint != null)

    var test_data := [
        {input = {weight = 1.0, stack_size = 1, max_stack_size = 1, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {weight = 1.0, stack_size = 1, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = {weight = 10.0, stack_size = 1, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 1.0, stack_size = 1, max_stack_size = 1, size = Vector2i(4, 4)}, expected = {has_space = false, space = ItemCount.zero()}},
        {input = {weight = 10.0, stack_size = 2, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        WeightConstraint.set_item_weight(item, data.input.weight)
        assert(grid_constraint.set_item_size(item, data.input.size))
        StacksConstraint.set_item_max_stack_size(item, data.input.max_stack_size)
        assert(StacksConstraint.set_item_stack_size(item, data.input.stack_size))
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_g_enforce_constraints() -> void:
    inventory.item_protoset = TEST_PROTOSET_G
    item.protoset = TEST_PROTOSET_G
    item.prototype_id = TEST_PROTOTYPE_G

    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var grid_constraint = constraint_manager.get_grid_constraint()
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
    new_item.free()


func test_wg_enforce_constraints() -> void:
    inventory.item_protoset = TEST_PROTOSET_G
    item.protoset = TEST_PROTOSET_G
    item.prototype_id = TEST_PROTOTYPE_G

    constraint_manager.enable_weight_constraint_(10.0)
    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var weight_constraint = constraint_manager.get_weight_constraint()
    var grid_constraint = constraint_manager.get_grid_constraint()
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
        if add_item_result:
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(item), item))
        
    inventory.remove_item(new_item)
    new_item.free()


func test_sg_enforce_constraints() -> void:
    inventory.item_protoset = TEST_PROTOSET_G

    constraint_manager.enable_stacks_constraint_()
    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var stacks_constraint := constraint_manager.get_stacks_constraint()
    var grid_constraint := constraint_manager.get_grid_constraint()
    assert(stacks_constraint != null)
    assert(grid_constraint != null)

    var new_item := inventory.create_and_add_item(TEST_PROTOTYPE_G)
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
        var test_item := InventoryItem.new()
        test_item.protoset = TEST_PROTOSET_G
        test_item.prototype_id = TEST_PROTOTYPE_G

        grid_constraint.size = data.input.inv_size
        StacksConstraint.set_item_max_stack_size(new_item, data.input.new_item_max_stack_size)
        assert(StacksConstraint.set_item_stack_size(new_item, data.input.new_item_stack_size))
        var add_item_result := inventory.add_item(test_item)
        assert(add_item_result == data.expected)
        if add_item_result && is_node_valid(test_item):
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(test_item), test_item))

        inventory.remove_item(test_item)
        test_item.free()

    inventory.remove_item(new_item)
    new_item.free()


func test_wsg_enforce_constraints() -> void:
    inventory.item_protoset = TEST_PROTOSET_G
    item.protoset = TEST_PROTOSET_G
    item.prototype_id = TEST_PROTOTYPE_G

    constraint_manager.enable_stacks_constraint_()
    constraint_manager.enable_weight_constraint_(10.0)
    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var stacks_constraint = constraint_manager.get_stacks_constraint()
    var weight_constraint = constraint_manager.get_weight_constraint()
    var grid_constraint = constraint_manager.get_grid_constraint()
    assert(stacks_constraint != null)
    assert(weight_constraint != null)
    assert(grid_constraint != null)

    var new_item = inventory.create_and_add_item(TEST_PROTOTYPE_G)
    assert(grid_constraint.get_item_position(new_item) == Vector2i.ZERO)

    # Test cases:
    # 1. Grid space available, stack space available, capacity available
    # 2. No grid space available, stack space available, capacity available
    # 3. Grid space available, no stack space available, capacity available
    # 4. Grid space available, stack space available, no capacity available
    # 5. No grid space available, no stack space available, capacity available
    # 6. Grid space available, no stack space available, no capacity available
    # 7. No grid space available, stack space available, no capacity available
    # 8. No grid space available, no stack space available, no capacity available
    var test_data := [
        {
            input = {inv_size = Vector2i(4, 4), new_item_stack_size = 1, new_item_max_stack_size = 2, item_weight = 1.0},
            expected = true,
        },
        {
            input = {inv_size = Vector2i(3, 3), new_item_stack_size = 1, new_item_max_stack_size = 2, item_weight = 1.0},
            expected = true,
        },
        {
            input = {inv_size = Vector2i(4, 4), new_item_stack_size = 1, new_item_max_stack_size = 1, item_weight = 1.0},
            expected = true,
        },
        {
            input = {inv_size = Vector2i(4, 4), new_item_stack_size = 1, new_item_max_stack_size = 2, item_weight = 11.0},
            expected = false,
        },
        {
            input = {inv_size = Vector2i(3, 3), new_item_stack_size = 1, new_item_max_stack_size = 1, item_weight = 1.0},
            expected = false,
        },
        {
            input = {inv_size = Vector2i(4, 4), new_item_stack_size = 1, new_item_max_stack_size = 1, item_weight = 11.0},
            expected = false,
        },
        {
            input = {inv_size = Vector2i(3, 3), new_item_stack_size = 1, new_item_max_stack_size = 2, item_weight = 11.0},
            expected = false,
        },
        {
            input = {inv_size = Vector2i(3, 3), new_item_stack_size = 1, new_item_max_stack_size = 1, item_weight = 11.0},
            expected = false,
        },
    ]

    for data in test_data:
        var test_item := InventoryItem.new()
        test_item.protoset = TEST_PROTOSET_G
        test_item.prototype_id = TEST_PROTOTYPE_G

        grid_constraint.size = data.input.inv_size
        StacksConstraint.set_item_max_stack_size(new_item, data.input.new_item_max_stack_size)
        assert(StacksConstraint.set_item_stack_size(new_item, data.input.new_item_stack_size))
        WeightConstraint.set_item_weight(test_item, data.input.item_weight)
        var add_item_result := inventory.add_item(test_item)
        assert(add_item_result == data.expected)
        if add_item_result && is_node_valid(test_item):
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(test_item), test_item))

        inventory.remove_item(test_item)
        test_item.free()

    inventory.remove_item(new_item)
    new_item.free()


func test_ws_transfer_autosplit() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    inventory2.item_protoset = TEST_PROTOSET_WS

    constraint_manager.enable_weight_constraint_(10.0)
    constraint_manager.enable_stacks_constraint_()
    var weight_constraint = constraint_manager.get_weight_constraint()
    var stacks_constraint = constraint_manager.get_stacks_constraint()
    assert(weight_constraint != null)
    assert(stacks_constraint != null)

    inventory2._constraint_manager.enable_weight_constraint_(3.0)
    inventory2._constraint_manager.enable_stacks_constraint_()
    assert(inventory2._constraint_manager.get_weight_constraint() != null)
    assert(inventory2._constraint_manager.get_stacks_constraint() != null)

    var test_data := [
        {
            input = {src_stack_size = 2, dst_stack_size = 1, dst_capacity = 10.0},
            expected = {return_val = true, src_stack_size = 2, dst_stack_size = 1, src_inv_count = 0, dst_inv_count = 2},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 1, dst_capacity = 10.0},
            expected = {return_val = true, src_stack_size = 3, dst_stack_size = 1, src_inv_count = 0, dst_inv_count = 2},
        },
        {
            input = {src_stack_size = 2, dst_stack_size = 1, dst_capacity = 2.0},
            expected = {return_val = true, src_stack_size = 1, dst_stack_size = 1, src_inv_count = 1, dst_inv_count = 2},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 3, dst_capacity = 10.0},
            expected = {return_val = true, src_stack_size = 3, dst_stack_size = 3, src_inv_count = 0, dst_inv_count = 2},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 1, dst_capacity = 1.0},
            expected = {return_val = false, src_stack_size = 3, dst_stack_size = 1, src_inv_count = 1, dst_inv_count = 1},
        },
    ]

    for data in test_data:
        var src_item := inventory.create_and_add_item(TEST_PROTOTYPE_WS)
        var dst_item := inventory2.create_and_add_item(TEST_PROTOTYPE_WS)

        inventory2._constraint_manager.get_weight_constraint().capacity = data.input.dst_capacity
        assert(StacksConstraint.set_item_stack_size(src_item, data.input.src_stack_size))
        assert(StacksConstraint.set_item_stack_size(dst_item, data.input.dst_stack_size))
        var result := stacks_constraint.transfer_autosplit(src_item, inventory2) != null
        assert(result == data.expected.return_val)
        assert(StacksConstraint.get_item_stack_size(src_item) == data.expected.src_stack_size)
        assert(StacksConstraint.get_item_stack_size(dst_item) == data.expected.dst_stack_size)
        assert(inventory.get_item_count() == data.expected.src_inv_count)
        assert(inventory2.get_item_count() == data.expected.dst_inv_count)

        clear_inventory(inventory)
        clear_inventory(inventory2)
        free_item(dst_item)
        free_item(src_item)


func test_sg_transfer_autosplit() -> void:
    inventory.item_protoset = TEST_PROTOSET_G
    inventory2.item_protoset = TEST_PROTOSET_G

    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    constraint_manager.enable_stacks_constraint_()
    var grid_constraint = constraint_manager.get_grid_constraint()
    var stacks_constraint = constraint_manager.get_stacks_constraint()
    assert(grid_constraint != null)
    assert(stacks_constraint != null)

    inventory2._constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    inventory2._constraint_manager.enable_stacks_constraint_()
    assert(inventory2._constraint_manager.get_grid_constraint() != null)
    assert(inventory2._constraint_manager.get_stacks_constraint() != null)

    # Test cases:
    # 1. Destination has place for the full stack without merging
    # 2. Destination has place for the full stack when merged
    # 3. Destination has place for part of the stack when merged
    # 4. Destination has no place for the stack
    var test_data := [
        {
            input = {src_stack_size = 3, dst_stack_size = 3, dst_inv_size = Vector2i(4, 4)},
            expected = {return_val = true, src_stack_size = 3, dst_stack_size = 3, src_inv_count = 0, dst_inv_count = 2},
        },
        {
            input = {src_stack_size = 2, dst_stack_size = 1, dst_inv_size = Vector2i(3, 3)},
            expected = {return_val = true, src_stack_size = 0, dst_stack_size = 3, src_inv_count = 0, dst_inv_count = 1},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 1, dst_inv_size = Vector2i(3, 3)},
            expected = {return_val = true, src_stack_size = 1, dst_stack_size = 3, src_inv_count = 1, dst_inv_count = 1},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 3, dst_inv_size = Vector2i(3, 3)},
            expected = {return_val = false, src_stack_size = 3, dst_stack_size = 3, src_inv_count = 1, dst_inv_count = 1},
        },
    ]

    for data in test_data:
        var src_item := inventory.create_and_add_item(TEST_PROTOTYPE_G)
        var dst_item := inventory2.create_and_add_item(TEST_PROTOTYPE_G)

        inventory2._constraint_manager.get_grid_constraint().size = data.input.dst_inv_size
        assert(StacksConstraint.set_item_stack_size(src_item, data.input.src_stack_size))
        StacksConstraint.set_item_max_stack_size(src_item, 3)
        assert(StacksConstraint.set_item_stack_size(dst_item, data.input.dst_stack_size))
        StacksConstraint.set_item_max_stack_size(dst_item, 3)
        var result := stacks_constraint.transfer_autosplit(src_item, inventory2) != null
        assert(result == data.expected.return_val)

        if data.expected.src_stack_size == 0:
            assert(!inventory.has_item(src_item))
            assert(src_item.is_queued_for_deletion())
        else:
            assert(StacksConstraint.get_item_stack_size(src_item) == data.expected.src_stack_size)

        if data.expected.dst_stack_size == 0:
            assert(!inventory2.has_item(dst_item))
            assert(dst_item.is_queued_for_deletion())
        else:
            assert(StacksConstraint.get_item_stack_size(dst_item) == data.expected.dst_stack_size)

        assert(inventory.get_item_count() == data.expected.src_inv_count)
        assert(inventory2.get_item_count() == data.expected.dst_inv_count)

        clear_inventory(inventory)
        clear_inventory(inventory2)
        free_item(dst_item)
        free_item(src_item)

    
func test_wsg_transfer_autosplit() -> void:
    inventory.item_protoset = TEST_PROTOSET_G
    inventory2.item_protoset = TEST_PROTOSET_G

    constraint_manager.enable_weight_constraint_(10.0)
    constraint_manager.enable_stacks_constraint_()
    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var weight_constraint = constraint_manager.get_weight_constraint()
    var stacks_constraint = constraint_manager.get_stacks_constraint()
    var grid_constraint = constraint_manager.get_grid_constraint()
    assert(weight_constraint != null)
    assert(grid_constraint != null)
    assert(stacks_constraint != null)

    inventory2._constraint_manager.enable_weight_constraint_(10.0)
    inventory2._constraint_manager.enable_stacks_constraint_()
    inventory2._constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    assert(inventory2._constraint_manager.get_weight_constraint() != null)
    assert(inventory2._constraint_manager.get_stacks_constraint() != null)
    assert(inventory2._constraint_manager.get_grid_constraint() != null)

    # Test cases
    # 1. Destination has place (capacity and space) for the full stack
    # 1. Destination has place (capacity and space) for the full stack when merged
    # 1. Destination only has space for part of the stack when merged
    # 1. Destination has capacity, but no space for part of the stack when merged
    # 1. Destination has no place for part of the stack
    var test_data := [
        {
            input = {src_stack_size = 3, dst_stack_size = 3, dst_inv_size = Vector2i(4, 4), dst_inv_capacity = 10.0},
            expected = {return_val = true, src_stack_size = 3, dst_stack_size = 3, src_inv_count = 0, dst_inv_count = 2},
        },
        {
            input = {src_stack_size = 2, dst_stack_size = 1, dst_inv_size = Vector2i(3, 3), dst_inv_capacity = 10.0},
            expected = {return_val = true, src_stack_size = 0, dst_stack_size = 3, src_inv_count = 0, dst_inv_count = 1},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 1, dst_inv_size = Vector2i(3, 3), dst_inv_capacity = 10.0},
            expected = {return_val = true, src_stack_size = 1, dst_stack_size = 3, src_inv_count = 1, dst_inv_count = 1},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 3, dst_inv_size = Vector2i(3, 3), dst_inv_capacity = 10.0},
            expected = {return_val = false, src_stack_size = 3, dst_stack_size = 3, src_inv_count = 1, dst_inv_count = 1},
        },
        {
            input = {src_stack_size = 3, dst_stack_size = 1, dst_inv_size = Vector2i(3, 3), dst_inv_capacity = 1.0},
            expected = {return_val = false, src_stack_size = 3, dst_stack_size = 1, src_inv_count = 1, dst_inv_count = 1},
        },
    ]

    for data in test_data:
        var src_item := inventory.create_and_add_item(TEST_PROTOTYPE_G)
        var dst_item := inventory2.create_and_add_item(TEST_PROTOTYPE_G)

        inventory2._constraint_manager.get_grid_constraint().size = data.input.dst_inv_size
        inventory2._constraint_manager.get_weight_constraint().capacity = data.input.dst_inv_capacity
        assert(StacksConstraint.set_item_stack_size(src_item, data.input.src_stack_size))
        StacksConstraint.set_item_max_stack_size(src_item, 3)
        assert(StacksConstraint.set_item_stack_size(dst_item, data.input.dst_stack_size))
        StacksConstraint.set_item_max_stack_size(dst_item, 3)
        var result := stacks_constraint.transfer_autosplit(src_item, inventory2) != null
        assert(result == data.expected.return_val)

        if data.expected.src_stack_size == 0:
            assert(!inventory.has_item(src_item))
            assert(src_item.is_queued_for_deletion())
        else:
            assert(StacksConstraint.get_item_stack_size(src_item) == data.expected.src_stack_size)

        if data.expected.dst_stack_size == 0:
            assert(!inventory2.has_item(dst_item))
            assert(dst_item.is_queued_for_deletion())
        else:
            assert(StacksConstraint.get_item_stack_size(dst_item) == data.expected.dst_stack_size)

        assert(inventory.get_item_count() == data.expected.src_inv_count)
        assert(inventory2.get_item_count() == data.expected.dst_inv_count)

        clear_inventory(inventory)
        clear_inventory(inventory2)
        free_item(dst_item)
        free_item(src_item)

