extends Inventory
class_name InventoryLimited

signal capacity_changed;
signal occupied_space_changed;

const KEY_WEIGHT: String = "weight";

export(float) var capacity: float setget _set_capacity;
var occupied_space: float;


static func get_type() -> String:
    return "stack";


static func get_item_script() -> Script:
    return preload("inventory_item_stackable.gd");


func _set_capacity(new_capacity: float) -> void:
    assert(new_capacity >= 0, "Capacity must be greater or equal to 0!");
    capacity = new_capacity;
    emit_signal("capacity_changed", capacity);


func _ready():
    _update_occupied_space();
    connect("contents_changed", self, "_on_contents_changed");


func _update_occupied_space() -> void:
    var old_occupied_space = occupied_space;
    occupied_space = 0.0;
    for item in get_items():
        occupied_space += _get_item_weight(item);

    if occupied_space != old_occupied_space:
        emit_signal("occupied_space_changed");
    assert(occupied_space <= capacity);


func _on_contents_changed():
    _update_occupied_space();


func get_free_space() -> float:
    var free_space: float = capacity - occupied_space;
    if free_space < 0.0:
        free_space = 0.0
    return free_space;


func has_place_for(item: InventoryItem) -> bool:
    return get_free_space() >= _get_item_weight(item);


func _get_item_weight(item: InventoryItem) -> float:
    var item_id = item.item_id;
    if item_definitions:
        return item_definitions.get_item_property(item_id, KEY_WEIGHT, 1.0);
    else:
        return 1.0;


func add_item(item: InventoryItem) -> bool:
    assert(item is InventoryItemStackable, "InventoryLimited can only hold InventoryItemStackable")
    if has_place_for(item):
        return .add_item(item);

    return false;


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    assert(destination.get_class() == get_class())
    if !destination.has_place_for(item):
        return false;
    
    return .transfer(item, destination);
