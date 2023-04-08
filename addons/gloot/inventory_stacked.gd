@tool
extends Inventory
class_name InventoryStacked

signal capacity_changed
signal occupied_space_changed

const KEY_WEIGHT: String = "weight"
const KEY_STACK_SIZE: String = "stack_size"
const KEY_MAX_STACK_SIZE: String = "max_stack_size"

const DEFAULT_STACK_SIZE: int = 1
const DEFAULT_MAX_STACK_SIZE: int = 100

@export var capacity: float :
    get:
        return capacity
    set(new_capacity):
        assert(new_capacity >= 0, "Capacity must be greater or equal to 0!")
        if !Engine.is_editor_hint():
            if new_capacity > 0.0 && occupied_space > new_capacity:
                return
        capacity = new_capacity
        update_configuration_warnings()
        emit_signal("capacity_changed")
var _occupied_space: float
var occupied_space: float :
    get:
        return _occupied_space
    set(new_occupied_space):
        assert(false, "occupied_space is read-only!")

const KEY_CAPACITY: String = "capacity"
const KEY_OCCUPIED_SPACE: String = "occupied_space"


func _get_configuration_warnings() -> PackedStringArray:
    if _occupied_space > capacity:
        return PackedStringArray(["Inventory capacity exceeded! %f/%f" % [_occupied_space, capacity]])
    return PackedStringArray()


func _get_default_item_weight(prototype_id: String) -> float:
    if item_protoset && item_protoset.has(prototype_id):
        var weight = item_protoset.get_item_property(prototype_id, KEY_WEIGHT, 1.0)
        var stack_size = item_protoset.get_item_property(prototype_id, KEY_STACK_SIZE, 1.0)
        return weight * stack_size
    return 1.0


func has_unlimited_capacity() -> bool:
    return capacity == 0.0


func _ready():
    super._ready()
    _calculate_occupied_space()
    connect("item_modified", Callable(self, "_on_item_modified"))


func _calculate_occupied_space() -> void:
    var old_occupied_space = occupied_space
    _occupied_space = 0.0
    for item in get_items():
        _occupied_space += _get_item_weight(item)

    if _occupied_space != old_occupied_space:
        emit_signal("occupied_space_changed")

    update_configuration_warnings()
    if !Engine.is_editor_hint():
        assert(has_unlimited_capacity() || occupied_space <= capacity, "Inventory overflow!")


func _on_item_added(item: InventoryItem) -> void:
    super._on_item_added(item)
    _calculate_occupied_space()
    update_configuration_warnings()


func _on_item_removed(item: InventoryItem) -> void:
    super._on_item_removed(item)
    _calculate_occupied_space()
    update_configuration_warnings()


func remove_item(item: InventoryItem) -> bool:
    var result = super.remove_item(item)
    _calculate_occupied_space()
    return result


func _on_item_modified(item: InventoryItem) -> void:
    _calculate_occupied_space()
    update_configuration_warnings()


func get_free_space() -> float:
    if has_unlimited_capacity():
        return capacity

    var free_space: float = capacity - _occupied_space
    if free_space < 0.0:
        free_space = 0.0
    return free_space


func has_place_for(item: InventoryItem) -> bool:
    if has_unlimited_capacity():
        return true

    return get_free_space() >= _get_item_weight(item)


func _get_item_unit_weight(item: InventoryItem) -> float:
    var weight = item.get_property(KEY_WEIGHT, 1.0)
    return weight


func _get_item_stack_size(item: InventoryItem) -> int:
    return item.get_property(KEY_STACK_SIZE, DEFAULT_STACK_SIZE)


func _get_item_max_stack_size(item: InventoryItem) -> int:
    return item.get_property(KEY_MAX_STACK_SIZE, DEFAULT_MAX_STACK_SIZE)


func _set_item_stack_size(item: InventoryItem, stack_size: int) -> void:
    item.set_property(KEY_STACK_SIZE, stack_size)


func _get_item_weight(item: InventoryItem) -> float:
    if item == null:
        return -1.0
    return _get_item_stack_size(item) * _get_item_unit_weight(item)


func add_item(item: InventoryItem) -> bool:
    if has_place_for(item):
        return super.add_item(item)

    return false


func add_item_automerge(item: InventoryItem) -> bool:
    if !has_place_for(item):
        return false

    var target_items = _get_mergable_items(item)
    target_items.sort_custom(Callable(self, "_compare_items_by_stack_size"))
    for target_item in target_items:
        _merge_stacks(item, target_item)
        if _get_item_stack_size(item) <= 0:
            _calculate_occupied_space()
            if item.get_inventory():
                item.get_inventory().remove_item(item)
            item.free()
            return true

    super.add_item(item)
    return true


func _get_mergable_items(item: InventoryItem) -> Array[InventoryItem]:
    var result: Array[InventoryItem] = []

    for i in get_items():
        if !_items_mergable(i, item):
            continue

        result.append(i)
            
    return result


func _items_mergable(item_1: InventoryItem, item_2: InventoryItem):
    # Two item stacks are mergable if they have the same prototype ID and neither of the two contain
    # custom properties that the other one doesn't have (except for "stack_size" and
    # "max_stack_size").

    if item_1.prototype_id != item_2.prototype_id:
        return false

    for property in item_1.properties.keys():
        if property == KEY_STACK_SIZE || property == KEY_MAX_STACK_SIZE:
            continue
        if !_has_custom_property(item_2, property, item_1.properties[property]):
            return false

    for property in item_2.properties.keys():
        if property == KEY_STACK_SIZE || property == KEY_MAX_STACK_SIZE:
            continue
        if !_has_custom_property(item_1, property, item_2.properties[property]):
            return false

    return true


func _has_custom_property(item: InventoryItem, property: String, value) -> bool:
    return item.properties.has(property) && item.properties[property] == value;


func _compare_items_by_stack_size(a: InventoryItem, b: InventoryItem) -> bool:
    return _get_item_stack_size(a) < _get_item_stack_size(b)


func _merge_stacks(item_src: InventoryItem, item_dst: InventoryItem) -> void:
    var src_size: int = _get_item_stack_size(item_src)
    if src_size <= 0:
        return

    var dst_size: int = _get_item_stack_size(item_dst)
    var dst_max_size: int = _get_item_max_stack_size(item_dst)
    var free_dst_stack_space: int = dst_max_size - dst_size
    if free_dst_stack_space <= 0:
        return

    _set_item_stack_size(item_dst, min(dst_size + src_size, dst_max_size))
    _set_item_stack_size(item_src, max(src_size - free_dst_stack_space, 0))


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    assert(destination.get_class() == get_class())
    if !destination.has_place_for(item):
        return false
    
    return super.transfer(item, destination)

    
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
    assert(super.add_item(new_item))
    return new_item


func join(stack_1: InventoryItem, stack_2: InventoryItem) -> bool:
    assert(has_item(stack_1) != null, "The inventory does not contain the given item!")
    assert(has_item(stack_2) != null, "The inventory does not contain the given item!")
    assert(stack_1.prototype_id == stack_2.prototype_id, "The two stacks must be of the same type!")

    if remove_item(stack_2):
        _set_item_stack_size(stack_1, _get_item_stack_size(stack_1) + _get_item_stack_size(stack_2))
        emit_signal("occupied_space_changed")
        _calculate_occupied_space()
        stack_2.free()
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
        return destination.add_item_automerge(item)

    return false


func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    if destination.has_place_for(item):
        return transfer_automerge(item, destination)

    var count: int = int(destination.get_free_space() / _get_item_unit_weight(item))
    if count > 0:
        var new_item: InventoryItem = split(item, count)
        assert(new_item != null)
        return transfer_automerge(new_item, destination)

    return false


func reset() -> void:
    super.reset()
    capacity = 0
    _occupied_space = 0


func serialize() -> Dictionary:
    var result: Dictionary = super.serialize()

    result[KEY_CAPACITY] = capacity
    result[KEY_OCCUPIED_SPACE] = _occupied_space

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_CAPACITY, TYPE_FLOAT) ||\
        !Verify.dict(source, true, KEY_OCCUPIED_SPACE, TYPE_FLOAT):
        return false

    reset()

    if !super.deserialize(source):
        return false

    capacity = source[KEY_CAPACITY]
    _occupied_space = source[KEY_OCCUPIED_SPACE]

    return true
