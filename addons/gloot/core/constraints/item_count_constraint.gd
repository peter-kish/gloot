@tool
@icon("res://addons/gloot/images/icon_item_count_constraint.svg")
extends InventoryConstraint
class_name ItemCountConstraint

const Verify = preload("res://addons/gloot/core/verify.gd")

const DEFAULT_CAPACITY = 1
const KEY_CAPACITY: String = "capacity"

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


func get_free_space() -> int:
    return max(0, capacity - get_occupied_space())


func get_occupied_space() -> int:
    if !is_instance_valid(inventory):
        return 0
    return inventory.get_item_count()


func get_space_for(item: InventoryItem) -> ItemCount:
    var free_stack_space := ItemCount.zero()
    for i in inventory.get_items():
        if Inventory.can_merge_stacks(i, item):
            free_stack_space.add(Inventory.get_free_stack_space(i))
    
    var free_space = ItemCount.new(get_free_space())
    free_space.mul(Inventory.get_item_max_stack_size(item))
    return free_stack_space.add(free_space)


func has_space_for(item:InventoryItem) -> bool:
    return get_occupied_space() < capacity


func reset() -> void:
    capacity = DEFAULT_CAPACITY


func serialize() -> Dictionary:
    var result := {}
    result[KEY_CAPACITY] = capacity
    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_CAPACITY, [TYPE_INT, TYPE_FLOAT]):
        return false

    reset()
    capacity = source[KEY_CAPACITY]

    return true
