extends TestSuite

var inventory: Inventory


func init_suite() -> void:
    tests = ["test_item_count"]


func init_test() -> void:
    inventory = Inventory.new()
    inventory.item_protoset = preload("res://tests/data/item_definitions_basic.tres")
    inventory.create_and_add_item("minimal_item")
    inventory.create_and_add_item("minimal_item")


func cleanup_test() -> void:
    free_inventory(inventory)


func test_item_count() -> void:
    var items = inventory.get_items()
    assert(items.size() == 2)

