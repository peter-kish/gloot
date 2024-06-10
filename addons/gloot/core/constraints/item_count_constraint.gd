@tool
@icon("res://addons/gloot/images/icon_item_count_constraint.svg")
extends InventoryConstraint
class_name ItemCountConstraint
## A constraint that limits the inventory to a given item count.
##
## The constraint implements a count-based inventory where the total number of items cannot exceed the configured
## capacity of the inventory.

const Verify = preload("res://addons/gloot/core/verify.gd")

const DEFAULT_CAPACITY = 1
const KEY_CAPACITY: String = "capacity"

## Maximum number of items the inventory can hold.
@export var capacity: int = DEFAULT_CAPACITY :
    set(new_capacity):
        if new_capacity < 1:
            new_capacity = 1
        if new_capacity == capacity:
            return
        if new_capacity > 0.0 && get_occupied_space() > new_capacity:
            return
        capacity = new_capacity
        changed.emit()


## Returns the number of items that can be added to the inventory.
func get_free_space() -> int:
    return max(0, capacity - get_occupied_space())


## Returns the total number of items in the inventory.
func get_occupied_space() -> int:
    if !is_instance_valid(inventory):
        return 0
    return inventory.get_item_count()


## Returns the number of times this constraint can receive the given item.
func get_space_for(item: InventoryItem) -> ItemCount:
    var free_stack_space := ItemCount.zero()
    for i in inventory.get_items():
        if item.can_merge_into(i):
            free_stack_space.add(i.get_free_stack_space())
    
    var free_space = ItemCount.new(get_free_space())
    free_space.mul(item.get_max_stack_size())
    return free_stack_space.add(free_space)


## Checks if the constraint can receive the given item.
func has_space_for(item:InventoryItem) -> bool:
    return get_occupied_space() < capacity


## Resets the constraint, i.e. sets its capacity to default (`1`).
func reset() -> void:
    capacity = DEFAULT_CAPACITY


## Serializes the constraint into a `Dictionary`.
func serialize() -> Dictionary:
    var result := {}
    result[KEY_CAPACITY] = capacity
    return result


## Loads the constraint data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_CAPACITY, [TYPE_INT, TYPE_FLOAT]):
        return false

    reset()
    capacity = source[KEY_CAPACITY]

    return true
