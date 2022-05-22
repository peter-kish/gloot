extends Node
class_name InventoryItem


export(String) var prototype_id: String;


func get_inventory() -> Node:
    return get_parent();


func apply(item_definition: Dictionary) -> void:
    prototype_id = item_definition[ItemDefinitions.KEY_ID];
