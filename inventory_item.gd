extends Node
class_name InventoryItem


export(String) var prototype_id: String;
var prototype: Dictionary = {};


func get_inventory() -> Node:
    return get_parent();
