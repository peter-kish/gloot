extends TestSuite

var inventory_3x3: InventoryGridStacked
var item_1x1: InventoryItem
var item_2x2: InventoryItem
var item_2x2_2: InventoryItem

const ItemStackManager = preload("res://addons/gloot/item_stack_manager.gd")


func init_suite():
    tests = [
        "test_has_place_for",
        "test_doesnt_have_place_for",
        "test_add_item_automerge",
    ]


func init_test():
    inventory_3x3 = InventoryGridStacked.new()
    inventory_3x3.item_protoset = preload("res://tests/data/item_definitions_grid.tres")
    inventory_3x3.size = Vector2i(3, 3)

    item_1x1 = InventoryItem.new()
    item_1x1.protoset = preload("res://tests/data/item_definitions_grid.tres")
    item_1x1.prototype_id = "item_1x1"

    item_2x2 = InventoryItem.new()
    item_2x2.protoset = preload("res://tests/data/item_definitions_grid.tres")
    item_2x2.prototype_id = "item_2x2"

    item_2x2_2 = InventoryItem.new()
    item_2x2_2.protoset = preload("res://tests/data/item_definitions_grid.tres")
    item_2x2_2.prototype_id = "item_2x2"


func cleanup_test() -> void:
    free_inventory(inventory_3x3)

    free_item(item_1x1)
    free_item(item_2x2)
    free_item(item_2x2_2)


func test_has_place_for() -> void:
    # Empty inventory
    assert(inventory_3x3.has_place_for(item_1x1))
    assert(inventory_3x3.has_place_for(item_2x2))
    
    # Inventory containing 1x1 item
    assert(inventory_3x3.add_item(item_1x1))
    assert(inventory_3x3.has_place_for(item_2x2))
    
    # Inventory containing 2x2 item
    item_2x2.set_property(ItemStackManager.KEY_MAX_STACK_SIZE, 1)
    assert(inventory_3x3.add_item(item_2x2))
    assert(!inventory_3x3.has_place_for(item_2x2_2))

    # Inventory containing 2x2 item with extended max_stack_size
    item_2x2.set_property(ItemStackManager.KEY_MAX_STACK_SIZE, 10)
    assert(inventory_3x3.has_place_for(item_2x2_2))


func test_add_item_automerge() -> void:
    # Empty inventory
    assert(inventory_3x3.add_item_automerge(item_2x2))
    assert(inventory_3x3.get_items().size() == 1)
    
    # Inventory containing 2x2 item
    assert(inventory_3x3.add_item_automerge(item_2x2_2))
    assert(inventory_3x3.get_items().size() == 1)
    assert(!is_instance_valid(item_2x2_2))

    item_2x2_2 = InventoryItem.new()
    item_2x2_2.protoset = preload("res://tests/data/item_definitions_grid.tres")
    item_2x2_2.prototype_id = "item_2x2"

    # No stack space, no grid space
    ItemStackManager.set_item_stack_size(item_2x2,
        ItemStackManager.get_item_max_stack_size(item_2x2))
    assert(!inventory_3x3.add_item_automerge(item_2x2_2))

    # No stack space but grid space available
    assert(inventory_3x3.add_item_automerge(item_1x1))

