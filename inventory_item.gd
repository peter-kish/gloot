extends Node
class_name InventoryItem


export(String) var prototype_id: String;


func get_inventory() -> Node:
    return get_parent();


func apply(item_prototype: Dictionary) -> void:
    prototype_id = item_prototype[ItemDefinitions.KEY_ID];
