extends Node
class_name TestSuite

export(bool) var enabled = true
var tests: Array


func run():
    if enabled:
        init_suite()
        _run_tests()
        cleanup_suite()


# Called before the tests suite is run
func init_suite() -> void:
    pass


# Called after the tests suite is run
func cleanup_suite() -> void:
    pass


# Called before a unit test is run
func init_test() -> void:
    pass
    
    
# Called after a unit test is run
func cleanup_test() -> void:
    pass


# Runs the test suite
func _run_tests():
    for test in tests:
        init_test()
        if has_method(test):
            print("Running %s:%s" % [name, test])
            call(test)
        else:
            print("Warning: Test %s:%s not found!" % [name, test])
        cleanup_test()


func clear_inventory(inventory: Inventory, exceptions: Array = []) -> void:
    while inventory.get_items().size() > 0:
        var item = inventory.get_items()[0]
        inventory.remove_item(item)
        # Free dynamically created items
        if not (item in exceptions):
            item.free()


func free_if_orphan(item: InventoryItem) -> void:
    if item != null && item.get_inventory() == null:
        item.free()
