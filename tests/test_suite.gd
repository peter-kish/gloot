extends Node
class_name TestSuite

@export var enabled: bool = true
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


# Free the given inventory, if valid
func free_inventory(inventory: Inventory) -> void:
    if inventory == null || !is_instance_valid(inventory):
        return
    while inventory.get_items().size() > 0:
        var item = inventory.get_items()[0]
        assert(inventory.remove_item(item))
        item.free()
    inventory.free()


# Free the given inventory item, if valid
func free_item(item) -> void:
    _free_if_valid(item)


# Free the given item slot, if valid
func free_slot(slot) -> void:
    _free_if_valid(slot)


func _free_if_valid(node) -> void:
    if node == null || !is_instance_valid(node):
        return
    node.free()
