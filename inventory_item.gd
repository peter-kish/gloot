extends Node
class_name InventoryItem


export(String) var item_id: String;


func get_inventory() -> Node:
    return get_parent();


func apply(item_definition: Dictionary) -> void:
    item_id = item_definition[ItemDefinitions.KEY_ID];