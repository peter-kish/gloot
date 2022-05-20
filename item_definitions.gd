class_name ItemDefinitions
extends Resource

const KEY_SYSTEM: String = "system";
const KEY_ITEMS: String = "items_prototypes";
const KEY_ID: String = "id";
const KEY_TYPE: String = "type";

export(String, MULTILINE) var json_data setget _set_json_data;

var definitions: Dictionary = {};
var inventory_type: String = "";


func _set_json_data(new_json_data: String) -> void:
    json_data = new_json_data;
    if !json_data.empty():
        parse(json_data);


func parse(json: String) -> void:
    definitions.clear();

    var def = parse_json(json);
    assert(def is Dictionary, "JSON file must contain an object!");

    assert(def.has(KEY_SYSTEM), "Item definitions must have a '%s' property" % KEY_SYSTEM);
    inventory_type = def[KEY_SYSTEM];
    assert(!inventory_type.empty(), "Invalid inventory type (empty string)!");
    assert(def.has(KEY_ITEMS), "Item definition must have an '%s' property!" % KEY_ITEMS);

    var items = def[KEY_ITEMS];
    assert(items is Array, "'%s' property must be an array!" % KEY_ITEMS);

    for item_def in items:
        assert(item_def is Dictionary, "Item definition must be a dictionary!");
        assert(item_def.has(KEY_ID), "Item definition must have an '%s' property!" % KEY_ID);
        assert(item_def[KEY_ID] is String, "'%s' property must be a string!" % KEY_ID);

        var id = item_def[KEY_ID];
        assert(!definitions.has(id), "Item definition ID '%s' already in use!" % id);
        definitions[id] = item_def;


func get(id: String) -> Dictionary:
    if definitions.has(id):
        return definitions[id];

    return {};


func get_item_property(id: String, property_name: String, default_value):
    var item_def = get(id);
    if !item_def.empty() && item_def.has(property_name):
        return item_def[property_name];
    
    return default_value;
