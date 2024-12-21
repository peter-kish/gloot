@tool
extends Node
class_name InventoryConstraint
## Base inventory constraint class.
##
## Base inventory constraint class which implements some basic constraint functionality and defines methods that can be
## overridden.

## Emitted when the state of the constraint has changed.
signal changed

## Reference to an inventory that this constraint belongs to.
var inventory: Inventory = null:
    set(new_inventory):
        inventory = new_inventory
        if is_instance_valid(inventory):
            _on_inventory_set()


func _notification(what: int) -> void:
    if what == NOTIFICATION_PARENTED:
        _on_parented(get_parent())
    elif what == NOTIFICATION_UNPARENTED:
        _on_unparented()


func _on_parented(parent: Node) -> void:
    if parent is Inventory:
        inventory = parent
        inventory._on_constraint_added(self)
    else:
        inventory = null
    update_configuration_warnings()


func _on_unparented() -> void:
    if inventory == null:
        return
    inventory._on_constraint_removed(self)
    inventory = null
    update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
    if inventory == null:
        return PackedStringArray([
            "InventoryConstraint nodes only serve to provide constraints to Inventory nodes. Please only use them as " \
            + "children of Inventory nodes."])
    return PackedStringArray()


## Returns the number of times this constraint can receive the given item.
func get_space_for(item: InventoryItem) -> int:
    return 0


## Checks if the constraint can receive the given item.
func has_space_for(item: InventoryItem) -> bool:
    return false


## Serializes the constraint into a `Dictionary`.
func serialize() -> Dictionary:
    return {}


## Loads the constraint data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    return true
    
    
## Called when constraint inventory is set/changed.
func _on_inventory_set() -> void:
    pass


## Called when an item is added to the inventory.
func _on_item_added(item: InventoryItem) -> void:
    pass


## Called when an item is removed from the inventory.
func _on_item_removed(item: InventoryItem) -> void:
    pass


## Called when an item property has changed.
func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    pass


## Called before the two given items are swapped.
func _on_pre_item_swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    return true


## Called after the two given items have been swapped.
func _on_post_item_swap(item1: InventoryItem, item2: InventoryItem) -> void:
    pass
