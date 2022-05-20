extends Node
class_name InventoryItem


export(String) var item_id: String;


func get_inventory() -> Node:
    return get_parent();

