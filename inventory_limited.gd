extends Inventory
class_name InventoryLimited


var capacity: float;
var occupied: float;


func _ready():
    connect("contents_changed", self, "_on_contents_changed");


func update_occupied_space() -> void:
    occupied = 0.0;
    for item in get_items():
        occupied += item.get_weight();


func _on_contents_changed():
    update_occupied_space();


func get_occupied_space() -> float:
    return occupied;


func get_free_space() -> float:
    var free_space: float = capacity - occupied;
    if free_space < 0.0:
        free_space = 0.0
    return free_space;


func has_place_for(item: InventoryItem) -> bool:
    return get_free_space() >= item.get_weight();


func add_item(item: InventoryItem) -> bool:
    if has_place_for(item):
        return .add_item(item);

    return false;