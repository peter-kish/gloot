extends Node
class_name InventoryItem


export(String) var item_name;
onready var sprite = $Sprite;


func get_weight() -> float:
    return 1.0;


func get_inventory() -> Node:
    if !get_parent() is Inventory:
        return null;
        
    return get_parent();
