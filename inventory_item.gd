extends Node
class_name InventoryItem

signal weight_changed;


export(String) var item_name;
var item_id: String;


func get_weight() -> float:
    return 1.0;


func get_inventory() -> Node:
    return get_parent();


# TODO: Introduce item classes? (weapon, armor, potion etc.)
