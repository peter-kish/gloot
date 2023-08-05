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


func create_inventory(protoset: ItemProtoset) -> Inventory:
    var inventory = Inventory.new()
    inventory.item_protoset = protoset
    return inventory


func create_inventory_stacked(protoset: ItemProtoset, capacity: float) -> InventoryStacked:
    var inventory = InventoryStacked.new()
    inventory.item_protoset = protoset
    inventory.capacity = capacity
    return inventory


func create_inventory_grid(protoset: ItemProtoset, size: Vector2i) -> InventoryGrid:
    var inventory = InventoryGrid.new()
    inventory.item_protoset = protoset
    inventory.size = size
    return inventory


func create_inventory_grid_stacked(protoset: ItemProtoset, size: Vector2i) -> InventoryGridStacked:
    var inventory = InventoryGridStacked.new()
    inventory.item_protoset = protoset
    inventory.size = size
    return inventory


# Create an item with the given prototype ID from the given protoset
func create_item(protoset: ItemProtoset, prototype_id: String) -> InventoryItem:
    var item = InventoryItem.new()
    item.protoset = protoset
    item.prototype_id = prototype_id
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
        item.free()


# Free the given inventory item, if valid
func free_item(item) -> void:
    _free_if_valid(item)


# Free the given item slot, if valid
func free_slot(slot) -> void:
    _free_if_valid(slot)


func _free_if_valid(node) -> void:
    if !is_node_valid(node):
        return
    node.free()


func is_node_valid(node) -> bool:
    return node != null && !node.is_queued_for_deletion() && is_instance_valid(node)

