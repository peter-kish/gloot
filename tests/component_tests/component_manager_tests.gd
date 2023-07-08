extends TestSuite

var inventory: Inventory
var item: InventoryItem
var component_manager: ComponentManager

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
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOSET, TEST_PROTOTYPE)
    inventory = create_inventory(TEST_PROTOSET)
    component_manager = ComponentManager.new()
    component_manager.inventory = inventory


func cleanup_test() -> void:
    free_item(item)
    free_inventory(inventory)


func test_init() -> void:
    assert(component_manager.get_weight_component() == null)
    assert(component_manager.get_stacks_component() == null)
    assert(component_manager.get_grid_component() == null)
    assert(component_manager.inventory == inventory)


func test_has_space_for() -> void:
    assert(component_manager.has_space_for(item))


func test_w_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    component_manager.enable_weight_component_(10.0)
    assert(component_manager.get_weight_component() != null)

    var test_data = [
        {input = 1.0, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = 10.0, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = 11.0, expected = {has_space = false, space = ItemCount.new(0)}},
    ]

    for data in test_data:
        WeightComponent.set_item_weight(item, data.input)
        assert(component_manager.has_space_for(item) == data.expected.has_space)
        assert(component_manager.get_space_for(item).eq(data.expected.space))


func test_s_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    component_manager.enable_stacks_component_()
    assert(component_manager.get_stacks_component() != null)

    var test_data = [
        {input = 1, expected = {has_space = true, space = ItemCount.new(ItemCount.Inf)}},
        {input = 11, expected = {has_space = true, space = ItemCount.new(ItemCount.Inf)}},
        {input = 111, expected = {has_space = true, space = ItemCount.new(ItemCount.Inf)}},
        {input = 1111, expected = {has_space = true, space = ItemCount.new(ItemCount.Inf)}},
    ]

    for data in test_data:
        StacksComponent.set_item_max_stack_size(item, data.input)
        StacksComponent.set_item_stack_size(item, data.input)
        assert(component_manager.has_space_for(item) == data.expected.has_space)
        assert(component_manager.get_space_for(item).eq(data.expected.space))


func test_g_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_G
    item.prototype_id = TEST_PROTOTYPE_G

    component_manager.enable_grid_component_(Vector2i(3, 3))
    var grid_component = component_manager.get_grid_component()
    assert(grid_component != null)

    var test_data = [
        {input = Vector2i(1, 1), expected = {has_space = true, space = ItemCount.new(9)}},
        {input = Vector2i(2, 2), expected = {has_space = true, space = ItemCount.new(1)}},
        {input = Vector2i(3, 3), expected = {has_space = true, space = ItemCount.new(1)}},
        {input = Vector2i(4, 4), expected = {has_space = false, space = ItemCount.new(0)}},
    ]

    for data in test_data:
        assert(grid_component.set_item_size(item, data.input))
        assert(component_manager.has_space_for(item) == data.expected.has_space)
        assert(component_manager.get_space_for(item).eq(data.expected.space))


func test_ws_has_space_for() -> void:
    item.prototype_id = TEST_PROTOTYPE_WS

    component_manager.enable_weight_component_(10.0)
    component_manager.enable_stacks_component_()
    var weight_component = component_manager.get_weight_component()
    var stacks_component = component_manager.get_stacks_component()
    assert(weight_component != null)
    assert(stacks_component != null)

    var test_data = [
        {input = {weight = 1.0, stack_size = 1}, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = {weight = 10.0, stack_size = 10}, expected = {has_space = false, space = ItemCount.new(1)}},
        {input = {weight = 10.0, stack_size = 1}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 1.0, stack_size = 10}, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = {weight = 11.0, stack_size = 1}, expected = {has_space = false, space = ItemCount.new(0)}},
        {input = {weight = 1.0, stack_size = 11}, expected = {has_space = false, space = ItemCount.new(10)}},
    ]

    for data in test_data:
        WeightComponent.set_item_weight(item, data.input.weight)
        StacksComponent.set_item_max_stack_size(item, data.input.stack_size)
        StacksComponent.set_item_stack_size(item, data.input.stack_size)
        assert(component_manager.has_space_for(item) == data.expected.has_space)
        assert(component_manager.get_space_for(item).eq(data.expected.space))


func test_wg_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    component_manager.enable_grid_component_(Vector2i(3, 3))
    component_manager.enable_weight_component_(10.0)
    var grid_component = component_manager.get_grid_component()
    var weight_component = component_manager.get_weight_component()
    assert(grid_component != null)
    assert(weight_component != null)

    var test_data = [
        {input = {weight = 1.0, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {weight = 10.0, size = Vector2i(3, 3)}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 11.0, size = Vector2i.ONE}, expected = {has_space = false, space = ItemCount.new(0)}},
        {input = {weight = 1.0, size = Vector2i(4, 4)}, expected = {has_space = false, space = ItemCount.new(0)}},
    ]

    for data in test_data:
        WeightComponent.set_item_weight(item, data.input.weight)
        assert(grid_component.set_item_size(item, data.input.size))
        assert(component_manager.has_space_for(item) == data.expected.has_space)
        assert(component_manager.get_space_for(item).eq(data.expected.space))


func test_sg_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    component_manager.enable_stacks_component_()
    component_manager.enable_grid_component_(Vector2i(3, 3))
    var stacks_component = component_manager.get_stacks_component()
    var grid_component = component_manager.get_grid_component()
    assert(stacks_component != null)
    assert(grid_component != null)

    var test_data = [
        {input = {stack_size = 1, max_stack_size = 1, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {stack_size = 1, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(18)}},
        {input = {stack_size = 1, max_stack_size = 2, size = Vector2i(3, 3)}, expected = {has_space = true, space = ItemCount.new(2)}},
        {input = {stack_size = 2, max_stack_size = 2, size = Vector2i(3, 3)}, expected = {has_space = true, space = ItemCount.new(2)}},
        {input = {stack_size = 2, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(18)}},
        {input = {stack_size = 2, max_stack_size = 2, size = Vector2i(4, 4)}, expected = {has_space = false, space = ItemCount.new(0)}},
    ]

    for data in test_data:
        assert(grid_component.set_item_size(item, data.input.size))
        StacksComponent.set_item_max_stack_size(item, data.input.max_stack_size)
        StacksComponent.set_item_stack_size(item, data.input.stack_size)
        assert(component_manager.has_space_for(item) == data.expected.has_space)
        assert(component_manager.get_space_for(item).eq(data.expected.space))


func test_wsg_has_space_for() -> void:
    inventory.item_protoset = TEST_PROTOSET_WS
    item.prototype_id = TEST_PROTOTYPE_WS

    component_manager.enable_weight_component_(10.0)
    component_manager.enable_stacks_component_()
    component_manager.enable_grid_component_(Vector2i(3, 3))
    var weight_component = component_manager.get_weight_component()
    var stacks_component = component_manager.get_stacks_component()
    var grid_component = component_manager.get_grid_component()
    assert(weight_component != null)
    assert(stacks_component != null)
    assert(grid_component != null)

    var test_data = [
        {input = {weight = 1.0, stack_size = 1, max_stack_size = 1, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {weight = 1.0, stack_size = 1, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = {weight = 10.0, stack_size = 1, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 1.0, stack_size = 1, max_stack_size = 1, size = Vector2i(4, 4)}, expected = {has_space = false, space = ItemCount.new(0)}},
        {input = {weight = 10.0, stack_size = 2, max_stack_size = 2, size = Vector2i.ONE}, expected = {has_space = false, space = ItemCount.new(1)}},
    ]

    for data in test_data:
        WeightComponent.set_item_weight(item, data.input.weight)
        assert(grid_component.set_item_size(item, data.input.size))
        StacksComponent.set_item_max_stack_size(item, data.input.max_stack_size)
        StacksComponent.set_item_stack_size(item, data.input.stack_size)
        assert(component_manager.has_space_for(item) == data.expected.has_space)
        assert(component_manager.get_space_for(item).eq(data.expected.space))
