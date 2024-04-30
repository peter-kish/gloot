extends TestSuite

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")

var inventory: Inventory
var item: InventoryItem
var item_2: InventoryItem
var stacks_constraint: StacksConstraint

const TEST_PROTOTREE = preload("res://tests/data/prototree_stacks.json")
const TEST_PROTOTYPE_PATH = "/stackable_item/limited_stackable_item"


func init_suite():
    tests = [
        "test_get_prototype_max_stack_size",
        "test_get_prototype_stack_size",
        "test_get_item_max_stack_size",
        "test_set_item_max_stack_size",
        "test_get_item_stack_size",
        "test_set_item_stack_size",
        "test_items_mergable",
        "test_get_mergable_items",
        "test_add_item_automerge_full",
        "test_add_item_automerge_fail",
        "test_add_item_automerge_partial",
        "test_split_stack",
        "test_stacks_joinable",
        "test_join_stacks",
        "test_join_stacks_autosplit",
        "test_get_space_for",
    ]


func init_test() -> void:
    item = create_item(TEST_PROTOTREE, TEST_PROTOTYPE_PATH)
    item_2 = create_item(TEST_PROTOTREE, TEST_PROTOTYPE_PATH)
    inventory = create_inventory(TEST_PROTOTREE)
    inventory.enable_stacks_constraint()
    stacks_constraint = inventory.get_stacks_constraint()


func cleanup_test() -> void:
    free_inventory(inventory)


func test_get_prototype_max_stack_size() -> void:
    assert(StacksConstraint.get_prototype_max_stack_size(item.protoset, TEST_PROTOTYPE_PATH) == 5)


func test_get_prototype_stack_size() -> void:
    assert(StacksConstraint.get_prototype_stack_size(item.protoset, TEST_PROTOTYPE_PATH) == 5)


func test_get_item_max_stack_size() -> void:
    assert(StacksConstraint.get_item_max_stack_size(item) == 5)


func test_set_item_max_stack_size() -> void:
    StacksConstraint.set_item_max_stack_size(item, 10)
    assert(StacksConstraint.get_item_max_stack_size(item) == 10)


func test_get_item_stack_size() -> void:
    assert(StacksConstraint.get_item_stack_size(item) == 5)


func test_set_item_stack_size() -> void:
    assert(StacksConstraint.set_item_stack_size(item, 4))
    assert(StacksConstraint.get_item_stack_size(item) == 4)

    assert(StacksConstraint.set_item_stack_size(item, 6) == false)
    assert(StacksConstraint.get_item_stack_size(item) == 4)

    inventory.add_item(item)
    assert(StacksConstraint.set_item_stack_size(item, 0))
    assert(!inventory.has_item(item))


func test_items_mergable() -> void:
    assert(StacksConstraint.items_mergable(item, item_2))
    
    assert(StacksConstraint.set_item_stack_size(item_2, 1))
    assert(StacksConstraint.items_mergable(item, item_2))

    StacksConstraint.set_item_max_stack_size(item_2, 10)
    assert(StacksConstraint.items_mergable(item, item_2))
    
    item_2.set_property("custom_property", "custom_value")
    assert(!StacksConstraint.items_mergable(item, item_2))
    
    item_2.clear_property("custom_property")
    assert(StacksConstraint.items_mergable(item, item_2))
    
    item_2.prototype_id = "minimal_item"
    assert(!StacksConstraint.items_mergable(item, item_2))


func test_get_mergable_items() -> void:
    assert(inventory.add_item(item))
    assert(inventory.add_item(item_2))
    var mergable_items = stacks_constraint.get_mergable_items(item)
    assert(mergable_items.size() == 1)
    assert(not item in mergable_items)
    assert(item_2 in mergable_items)


func test_add_item_automerge_full() -> void:
    assert(StacksConstraint.set_item_stack_size(item, 1))
    assert(StacksConstraint.set_item_stack_size(item_2, 1))
    assert(inventory.add_item(item))
    stacks_constraint.add_item_automerge(item_2)
    assert(inventory.get_item_count() == 1)
    assert(StacksConstraint.get_item_stack_size(item) == 2)
    assert(!inventory.has_item(item_2))


func test_add_item_automerge_fail() -> void:
    assert(inventory.add_item(item))
    stacks_constraint.add_item_automerge(item_2)
    assert(inventory.get_item_count() == 2)
    assert(StacksConstraint.get_item_stack_size(item) == 5)
    assert(StacksConstraint.get_item_stack_size(item_2) == 5)
    assert(inventory.has_item(item_2))


func test_add_item_automerge_partial() -> void:
    assert(StacksConstraint.set_item_stack_size(item, 3))
    assert(inventory.add_item(item))
    stacks_constraint.add_item_automerge(item_2)
    assert(inventory.get_item_count() == 2)
    assert(StacksConstraint.get_item_stack_size(item) == 5)
    assert(StacksConstraint.get_item_stack_size(item_2) == 3)
    assert(inventory.has_item(item_2))


func test_split_stack() -> void:
    var new_item = StacksConstraint.split_stack(item, 3)
    assert(StacksConstraint.get_item_stack_size(item) == 2)
    assert(StacksConstraint.get_item_stack_size(new_item) == 3)


func test_stacks_joinable() -> void:
    inventory.add_item(item)
    inventory.add_item(item_2)
    assert(!StacksConstraint.stacks_joinable(item, item_2))

    assert(StacksConstraint.set_item_stack_size(item, 1))
    assert(StacksConstraint.set_item_stack_size(item_2, 1))
    assert(StacksConstraint.stacks_joinable(item, item_2))
    
    item_2.set_property("custom_property", "custom_value")
    assert(!StacksConstraint.stacks_joinable(item, item_2))


func test_join_stacks() -> void:
    inventory.add_item(item)
    inventory.add_item(item_2)
    assert(!StacksConstraint.join_stacks(item, item_2))
    assert(inventory.get_item_count() == 2)
    
    assert(StacksConstraint.set_item_stack_size(item, 1))
    assert(StacksConstraint.set_item_stack_size(item_2, 1))
    assert(StacksConstraint.join_stacks(item, item_2))
    assert(inventory.get_item_count() == 1)
    assert(StacksConstraint.get_item_stack_size(item) == 2)
    assert(StacksConstraint.get_item_stack_size(item_2) == 0)


func test_join_stacks_autosplit() -> void:
    inventory.add_item(item)
    inventory.add_item(item_2)
    assert(StacksConstraint.set_item_stack_size(item, 3))
    assert(StacksConstraint.set_item_stack_size(item_2, 5))

    assert(stacks_constraint.join_stacks_autosplit(item, item_2))
    assert(inventory.get_item_count() == 2)
    assert(StacksConstraint.get_item_stack_size(item) == 5)
    assert(StacksConstraint.get_item_stack_size(item_2) == 3)


func test_get_space_for() -> void:
    var inf = ItemCount.inf()
    stacks_constraint.get_space_for(item).eq(inf)
    stacks_constraint.get_space_for(item_2).eq(inf)
