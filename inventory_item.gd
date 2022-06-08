extends Node
class_name InventoryItem

export(Resource) var protoset;
export(String) var prototype_id: String;


func get_inventory() -> Node:
    return get_parent();


func get_prototype() -> Dictionary:
    assert(protoset, "Item protoset must be set in order to get its prototype!");
    assert(!prototype_id.empty(), "Item prototype_id must be set in order to get its prototype!");
    return protoset.get(prototype_id);


func get_prototype_property(property_name: String, default_value = null):
    if get_prototype().has(property_name):
        return get_prototype()[property_name];
    return default_value;
