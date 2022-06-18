extends Node
class_name InventoryItem

export(Resource) var protoset;
export(String) var prototype_id: String;
var properties: Dictionary;

const PROTOSET_KEY: String = "protoset";
const PROTOTYE_ID_KEY: String = "prototype_id";
const PROPERTIES_KEY: String = "properties";


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


func _reset() -> void:
    protoset = null;
    prototype_id = "";
    properties = {};


func serialize() -> Dictionary:
    var result: Dictionary = {};

    result[PROTOSET_KEY] = protoset.resource_path;
    result[PROTOTYE_ID_KEY] = prototype_id;
    if !properties.empty():
        result[PROPERTIES_KEY] = properties;

    return result;


func deserialize(source: Dictionary) -> bool:
    if !GlootVerify.dict(source, true, PROTOSET_KEY, TYPE_STRING) ||\
        !GlootVerify.dict(source, true, PROTOTYE_ID_KEY, TYPE_STRING) ||\
        !GlootVerify.dict(source, false, PROPERTIES_KEY, TYPE_DICTIONARY):
        return false;

    _reset();

    protoset = load(source[PROTOSET_KEY]);
    prototype_id = source[PROTOTYE_ID_KEY];
    if source.has(PROPERTIES_KEY):
        properties = source[PROPERTIES_KEY];

    return true;
