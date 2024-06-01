@tool
@icon("res://addons/gloot/images/icon_weight_constraint.svg")
extends InventoryConstraint
class_name WeightConstraint

const DEFAULT_CAPACITY: float = 1.0
const KEY_WEIGHT: String = "weight"
const KEY_CAPACITY: String = "capacity"
const KEY_OCCUPIED_SPACE: String = "occupied_space"

const Verify = preload("res://addons/gloot/core/verify.gd")


@export var capacity: float = DEFAULT_CAPACITY :
    set(new_capacity):
        if new_capacity < 0.0:
            new_capacity = 0.0
        if new_capacity == capacity:
            return
        if new_capacity > 0.0 && _occupied_space > new_capacity:
            return
        capacity = new_capacity
        changed.emit()

var _occupied_space: float


func get_occupied_space() -> float:
    return _occupied_space
    
    
func _on_inventory_set() -> void:
    _calculate_occupied_space()


func _on_item_added(item: InventoryItem) -> void:
    _calculate_occupied_space()


func _on_item_removed(item: InventoryItem) -> void:
    _calculate_occupied_space()

    
func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    if property == KEY_WEIGHT || property == Inventory.KEY_STACK_SIZE:
        _calculate_occupied_space()


func _on_pre_item_swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    return _can_swap(item1, item2) && _can_swap(item2, item1)


static func _can_swap(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    var inv = item_dst.get_inventory()
    if !is_instance_valid(inv):
        return true

    var weight_constraint = inv._constraint_manager.get_constraint(WeightConstraint)
    if !is_instance_valid(weight_constraint):
        return true

    var space_needed: float = weight_constraint._occupied_space - get_item_weight(item_dst) + get_item_weight(item_src)
    return space_needed <= weight_constraint.capacity


func get_free_space() -> float:
    var free_space: float = capacity - _occupied_space
    if free_space < 0.0:
        free_space = 0.0
    return free_space


func _calculate_occupied_space() -> void:
    var old_occupied_space = _occupied_space
    _occupied_space = 0.0
    for item in inventory.get_items():
        _occupied_space += get_item_weight(item)

    if _occupied_space != old_occupied_space:
        changed.emit()

    if !Engine.is_editor_hint():
        assert(_occupied_space <= capacity, "Inventory overflow!")


static func _get_item_unit_weight(item: InventoryItem) -> float:
    var weight = item.get_property(KEY_WEIGHT, 1.0)
    return weight


static func get_item_weight(item: InventoryItem) -> float:
    if item == null:
        return -1.0
    # TODO: Handle infinity?
    return Inventory.get_item_stack_size(item).count * _get_item_unit_weight(item)


static func set_item_weight(item: InventoryItem, weight: float) -> void:
    assert(weight >= 0.0, "Item weight must be greater or equal to 0!")
    item.set_property(KEY_WEIGHT, weight)


func get_space_for(item: InventoryItem) -> ItemCount:
    var unit_weight := _get_item_unit_weight(item)
    return ItemCount.new(floor(get_free_space() / unit_weight))


func has_space_for(item: InventoryItem) -> bool:
    var item_weight := get_item_weight(item)
    return get_free_space() >= item_weight


func reset() -> void:
    capacity = 0.0


func serialize() -> Dictionary:
    var result := {}

    result[KEY_CAPACITY] = capacity

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_CAPACITY, TYPE_FLOAT):
        return false

    reset()
    capacity = source[KEY_CAPACITY]
    _calculate_occupied_space()

    return true


