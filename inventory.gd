extends Node
class_name Inventory

signal item_added;
signal item_removed;
signal contents_changed;


func _ready():
    for item in get_items():
        if item is InventoryItem:
            item.connect("weight_changed", self, "_on_item_weight_changed");


func get_items() -> Array:
    return get_children();


func has_item(item: InventoryItem) -> bool:
    return get_children().find(item) != -1;


func add_item(item: InventoryItem) -> bool:
    if has_item(item):
        return false;

    if item.get_parent():
        item.get_parent().remove_child(item);

    add_child(item);
    emit_signal("item_added", item);
    emit_signal("contents_changed");
    item.connect("weight_changed", self, "_on_item_weight_changed");
    return true;


func _on_item_weight_changed(_new_weight: float):
    emit_signal("contents_changed");


func remove_item(item: InventoryItem) -> bool:
    if !has_item(item):
        return false;

    remove_child(item);
    emit_signal("item_removed", item);
    emit_signal("contents_changed");
    item.disconnect("weight_changed", self, "_on_item_weight_changed");
    return true;

    
func get_item_by_name(name: String) -> InventoryItem:
    for item in get_children():
        if item.name == name:
            return item;
            
    return null;


func has_item_by_name(name: String) -> bool:
    return get_item_by_name(name) != null;


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    if remove_item(item):
        return destination.add_item(item);

    return false;

