extends Inventory
class_name InventoryStacked
tool

signal capacity_changed
signal occupied_space_changed

const KEY_WEIGHT: String = "weight"
const KEY_STACK_SIZE: String = "stack_size"
const DEFAULT_STACK_SIZE: int = 1

export(float) var capacity: float setget _set_capacity
var occupied_space: float setget _set_occupied_space

const KEY_CAPACITY: String = "capacity"
const KEY_OCCUPIED_SPACE: String = "occupied_space"


func _get_configuration_warning() -> String:
    if occupied_space > capacity:
        return "Inventory capacity exceeded! %f/%f" % [occupied_space, capacity]
    return ""


func _get_default_item_weight(prototype_id: String) -> float:
    if item_protoset && item_protoset.has(prototype_id):
        var weight = item_protoset.get_item_property(prototype_id, KEY_WEIGHT, 1.0)
        var stack_size = item_protoset.get_item_property(prototype_id, KEY_STACK_SIZE, 1.0)
        return weight * stack_size
    return 1.0


func has_unlimited_capacity() -> bool:
    return capacity == 0.0


func _set_capacity(new_capacity: float) -> void:
    assert(new_capacity >= 0, "Capacity must be greater or equal to 0!")
    if !Engine.editor_hint:
        if new_capacity > 0.0 && occupied_space > new_capacity:
            return
    capacity = new_capacity
    update_configuration_warning()
    emit_signal("capacity_changed")


func _set_occupied_space(new_occupied_space: float) -> void:
    assert(false, "occupied_space is read-only!")


func _ready():
    _calculate_occupied_space()
    connect("item_modified", self, "_on_item_modified")


func _calculate_occupied_space() -> void:
    var old_occupied_space = occupied_space
    occupied_space = 0.0
    for item in get_items():
        occupied_space += _get_item_weight(item)

    if occupied_space != old_occupied_space:
        emit_signal("occupied_space_changed")

    update_configuration_warning()
    if !Engine.editor_hint:
        assert(has_unlimited_capacity() || occupied_space <= capacity, "Inventory overflow!")


func _on_item_added(item: InventoryItem) -> void:
    ._on_item_added(item)
    _calculate_occupied_space()
    update_configuration_warning()


func _on_item_removed(item: InventoryItem) -> void:
    ._on_item_removed(item)
    _calculate_occupied_space()
    update_configuration_warning()


func remove_item(item: InventoryItem) -> bool:
    var result = .remove_item(item)
    _calculate_occupied_space()
    return result


func _on_item_modified(item: InventoryItem) -> void:
    _calculate_occupied_space()
    update_configuration_warning()


func get_free_space() -> float:
    if has_unlimited_capacity():
        return capacity

    var free_space: float = capacity - occupied_space
    if free_space < 0.0:
        free_space = 0.0
    return free_space


func has_place_for(item: InventoryItem) -> bool:
    if has_unlimited_capacity():
        return true

    return get_free_space() >= _get_item_weight(item)


func _get_item_unit_weight(item: InventoryItem) -> float:
    var weight = item.get_property(KEY_WEIGHT, 1.0)
    if weight is float:
        return weight
    return 1.0


func _get_item_stack_size(item: InventoryItem) -> int:
    return item.get_property(KEY_STACK_SIZE, DEFAULT_STACK_SIZE)


func _set_item_stack_size(item: InventoryItem, stack_size: int) -> void:
    item.set_property(KEY_STACK_SIZE, stack_size)


func _get_item_weight(item: InventoryItem) -> float:
    if item == null:
        return -1.0
    return _get_item_stack_size(item) * _get_item_unit_weight(item)


func add_item(item: InventoryItem) -> bool:
    if has_place_for(item):
        return .add_item(item)

    return false


func _add_item_automerge(item: InventoryItem) -> bool:
    if !has_place_for(item):
        return false

    var target_item = get_item_by_id(item.prototype_id)
    if target_item:
        add_item(item)
        join(target_item, item)
        return true
    else:
        return add_item(item)


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    assert(destination.get_class() == get_class())
    if !destination.has_place_for(item):
        return false
    
    return .transfer(item, destination)

    
func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    assert(has_item(item) != null, "The inventory does not contain the given item!")
    assert(new_stack_size >= 1, "New stack size must be greater or equal to 1!")

    var stack_size = _get_item_stack_size(item)
    assert(new_stack_size < stack_size, "New stack size must be smaller than the original stack size!")

    var new_item = item.duplicate()
    _set_item_stack_size(new_item, new_stack_size)
    _set_item_stack_size(item, stack_size - new_stack_size)
    emit_signal("occupied_space_changed")
    _calculate_occupied_space()
    assert(add_item(new_item))
    return new_item


func join(stack_1: InventoryItem, stack_2: InventoryItem) -> bool:
    assert(has_item(stack_1) != null, "The inventory does not contain the given item!")
    assert(has_item(stack_2) != null, "The inventory does not contain the given item!")
    assert(stack_1.prototype_id == stack_2.prototype_id, "The two stacks must be of the same type!")

    if remove_item(stack_2):
        _set_item_stack_size(stack_1, _get_item_stack_size(stack_1) + _get_item_stack_size(stack_2))
        emit_signal("occupied_space_changed")
        _calculate_occupied_space()
        stack_2.queue_free()
        return true

    return false


func transfer_autosplit(item: InventoryItem, destination: Inventory) -> bool:
    if destination.has_place_for(item):
        return transfer(item, destination)

    var count: int = int(destination.get_free_space()) / int(_get_item_unit_weight(item))
    if count > 0:
        var new_item: InventoryItem = split(item, count)
        assert(new_item != null)
        return transfer(new_item, destination)

    return false


func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
    if destination.has_place_for(item) && remove_item(item):
        return destination._add_item_automerge(item)

    return false


func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    if destination.has_place_for(item):
        return transfer_automerge(item, destination)

    var count: int = int(destination.get_free_space()) / int(_get_item_unit_weight(item))
    if count > 0:
        var new_item: InventoryItem = split(item, count)
        assert(new_item != null)
        return transfer_automerge(new_item, destination)

    return false


func reset() -> void:
    .reset()
    capacity = 0
    occupied_space = 0


func serialize() -> Dictionary:
    var result: Dictionary = .serialize()

    result[KEY_CAPACITY] = capacity
    result[KEY_OCCUPIED_SPACE] = occupied_space

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_CAPACITY, TYPE_REAL) ||\
        !Verify.dict(source, true, KEY_OCCUPIED_SPACE, TYPE_REAL):
        return false

    reset()

    if !.deserialize(source):
        return false

    capacity = source[KEY_CAPACITY]
    occupied_space = source[KEY_OCCUPIED_SPACE]

    return true
