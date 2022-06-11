extends Node
class_name InventoryItem

export(Resource) var protoset;
export(String) var prototype_id: String;
var properties: Dictionary;


func get_inventory() -> Node:
    return get_parent();


func get_property(property_name: String, default_value = null):
    if properties.has(property_name):
        return properties[property_name];
    if protoset:
        return protoset.get_item_property(prototype_id, property_name, default_value);
    return default_value;


func set_property(property_name: String, value) -> void:
    properties[property_name] = value;


func clear_property(property_name: String) -> void:
    properties.erase(property_name);
