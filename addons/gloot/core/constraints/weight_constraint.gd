extends "res://addons/gloot/core/constraints/inventory_constraint.gd"

signal capacity_changed
signal occupied_space_changed

const KEY_WEIGHT: String = "weight"
const KEY_CAPACITY: String = "capacity"
const KEY_OCCUPIED_SPACE: String = "occupied_space"

const Verify = preload("res://addons/gloot/core/verify.gd")
const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")


var capacity: float :
    get:
        return capacity
    set(new_capacity):
        if new_capacity < 0.0:
            new_capacity = 0.0
        if new_capacity == capacity:
            return
        if new_capacity > 0.0 && occupied_space > new_capacity:
            return
        capacity = new_capacity
        capacity_changed.emit()

var _occupied_space: float
var occupied_space: float :
    get:
        return _occupied_space
    set(new_occupied_space):
        assert(false, "occupied_space is read-only!")


func _init(inventory: Inventory) -> void:
    super._init(inventory)
    
    
func _on_inventory_set() -> void:
    _calculate_occupied_space()


func _on_item_added(item: InventoryItem) -> void:
    _calculate_occupied_space()


func _on_item_removed(item: InventoryItem) -> void:
    _calculate_occupied_space()

    
func _on_item_modified(item: InventoryItem) -> void:
    _calculate_occupied_space()


func has_unlimited_capacity() -> bool:
    return capacity == 0.0


func get_free_space() -> float:
    if has_unlimited_capacity():
        return capacity

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
        emit_signal("occupied_space_changed")

    if !Engine.is_editor_hint():
        assert(has_unlimited_capacity() || _occupied_space <= capacity, "Inventory overflow!")


static func _get_item_unit_weight(item: InventoryItem) -> float:
    var weight = item.get_property(KEY_WEIGHT, 1.0)
    return weight


static func get_item_weight(item: InventoryItem) -> float:
    if item == null:
        return -1.0
    return StacksConstraint.get_item_stack_size(item) * _get_item_unit_weight(item)


static func set_item_weight(item: InventoryItem, weight: float) -> void:
    assert(weight >= 0.0, "Item weight must be greater or equal to 0!")
    item.set_property(KEY_WEIGHT, weight)


func get_space_for(item: InventoryItem) -> ItemCount:
    if has_unlimited_capacity():
        return ItemCount.inf()
    var unit_weight := _get_item_unit_weight(item)
    return ItemCount.new(floor(get_free_space() / unit_weight))


func reset() -> void:
    capacity = 0.0


func serialize() -> Dictionary:
    var result := {}

    result[KEY_CAPACITY] = capacity
    # TODO: Check if this is needed
    result[KEY_OCCUPIED_SPACE] = _occupied_space

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_CAPACITY, TYPE_FLOAT) ||\
        !Verify.dict(source, true, KEY_OCCUPIED_SPACE, TYPE_FLOAT):
        return false

    reset()
    capacity = source[KEY_CAPACITY]
    # TODO: Check if this is needed
    _occupied_space = source[KEY_OCCUPIED_SPACE]

    return true


