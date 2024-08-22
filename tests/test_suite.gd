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


func create_inventory(protoset: JSON) -> Inventory:
    var inventory = Inventory.new()
    inventory.protoset = protoset
    return inventory


func create_inventory_stacked(protoset: JSON, capacity: float) -> Inventory:
    var inventory = Inventory.new()
    inventory.protoset = protoset
    enable_weight_constraint(inventory, capacity)

    return inventory


func create_inventory_grid(protoset: JSON, size: Vector2i) -> Inventory:
    var inventory = Inventory.new()
    inventory.protoset = protoset
    enable_grid_constraint(inventory, size)

    return inventory


func enable_weight_constraint(inventory: Inventory, capacity: float = WeightConstraint.DEFAULT_CAPACITY) -> WeightConstraint:
    var weight_constraint = WeightConstraint.new()
    weight_constraint.capacity = capacity
    inventory.add_child(weight_constraint)
    return weight_constraint


func enable_grid_constraint(inventory: Inventory, size: Vector2i = GridConstraint.DEFAULT_SIZE) -> GridConstraint:
    var grid_constraint = GridConstraint.new()
    grid_constraint.size = size
    inventory.add_child(grid_constraint)
    return grid_constraint


func enable_item_count_constraint(inventory: Inventory, capacity: int = ItemCountConstraint.DEFAULT_CAPACITY) -> ItemCountConstraint:
    var item_count_constraint = ItemCountConstraint.new()
    item_count_constraint.capacity = capacity
    inventory.add_child(item_count_constraint)
    return item_count_constraint


# Create an item with the given prototype ID from the given protoset
func create_item(protoset: JSON, prototype_id: String) -> InventoryItem:
    var item = InventoryItem.new(protoset, prototype_id)
    return item


# Free the given inventory, if valid
func free_inventory(inventory: Inventory) -> void:
    if !is_node_valid(inventory):
        return
    clear_inventory(inventory)
    inventory.free()


# Clear all inventory items
func clear_inventory(inventory: Inventory) -> void:
    while inventory.get_item_count() > 0:
        var item = inventory.get_items()[0]
        assert(inventory.remove_item(item))


# Free the given item slot, if valid
func free_slot(slot) -> void:
    if !is_node_valid(slot):
        return
    slot.free()


func _free_if_valid(node) -> void:
    if !is_node_valid(node):
        return
    node.free()


func is_node_valid(node) -> bool:
    return node != null && !node.is_queued_for_deletion() && is_instance_valid(node)
