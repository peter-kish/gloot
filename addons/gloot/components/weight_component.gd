class_name WeightComponent
extends InventoryComponent

signal capacity_changed
signal occupied_space_changed

const KEY_WEIGHT: String = "weight"


var capacity: float :
    get:
        return capacity
    set(new_capacity):
        if new_capacity < 0.0:
            new_capacity = 0.0
        if new_capacity == capacity:
            return
        capacity = new_capacity
        capacity_changed.emit()

var _occupied_space: float
var occupied_space: float :
    get:
        return _occupied_space
    set(new_occupied_space):
        assert(false, "occupied_space is read-only!")


func _init() -> void:
    inventory_set.connect(Callable(self, "_on_inventory_set"))
    
    
func _on_inventory_set() -> void:
    _connect_inventory_signals()
    _calculate_occupied_space()


func _connect_inventory_signals() -> void:
    inventory.item_added.connect(Callable(self, "_calculate_occupied_space_proxy"))
    inventory.item_removed.connect(Callable(self, "_calculate_occupied_space_proxy"))
    inventory.item_modified.connect(Callable(self, "_calculate_occupied_space_proxy"))


func _calculate_occupied_space_proxy(_item: InventoryItem) -> void:
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
    var old_occupied_space = occupied_space
    _occupied_space = 0.0
    for item in inventory.get_items():
        _occupied_space += get_item_weight(item)

    if _occupied_space != old_occupied_space:
        emit_signal("occupied_space_changed")

    if !Engine.is_editor_hint():
        assert(has_unlimited_capacity() || occupied_space <= capacity, "Inventory overflow!")


static func _get_item_unit_weight(item: InventoryItem) -> float:
    var weight = item.get_property(KEY_WEIGHT, 1.0)
    return weight


static func get_item_weight(item: InventoryItem) -> float:
    if item == null:
        return -1.0
    return StacksComponent.get_item_stack_size(item) * _get_item_unit_weight(item)


static func set_item_weight(item: InventoryItem, weight: float) -> void:
    assert(weight >= 0.0, "Item weight must be greater or equal to 0!")
    item.set_property(KEY_WEIGHT, weight)


func get_space_for(item: InventoryItem) -> ItemCount:
    if has_unlimited_capacity():
        return ItemCount.new(ItemCount.Inf)
    var unit_weight := _get_item_unit_weight(item)
    return ItemCount.new(floor(get_free_space() / unit_weight))