extends Node

enum ItemType {Unknown = 0, Basic = 1, Stackable = 2, Weight = 3, Rect = 4};

const ITEM_TYPE_NAMES: Array = [
    "unknown",
    "basic",
    "stackable",
    "weight",
    "rect"
];
const KEY_ID: String = "id";
const KEY_TYPE: String = "type";
const KEY_STACK_SIZE: String = "default_stack_size";
const KEY_WEIGHT: String = "weight";
const KEY_WIDTH: String = "width";
const KEY_HEIGHT: String = "height";

var definitions: Dictionary = {};


func strToItemType(item_type_string: String) -> int:
    for i in range(ITEM_TYPE_NAMES.size()):
        if ITEM_TYPE_NAMES[i] == item_type_string:
            return i;

    return ItemType.Unknown;


func parse(json: String) -> void:
    definitions.clear();

    var def = parse_json(json);
    assert(def is Array, "JSON file must be an array!");

    for item_def in def:
        assert(item_def is Dictionary, "Item definition must be a dictionary!");
        assert(item_def.has(KEY_ID), "Item definition must have an '%s' property!" % KEY_ID);
        assert(item_def[KEY_ID] is String, "'%s' property must be a string!" % KEY_ID);
        
        var type: int = ItemType.Basic;
        if item_def.has(KEY_TYPE):
            assert(item_def[KEY_TYPE] is String, "'%s' property must be a string!" % KEY_TYPE);
            type = strToItemType(item_def[KEY_TYPE]);
            assert(type != ItemType.Unknown, "Unknown item type!");

        # Convert the type from string to int
        item_def[KEY_TYPE] = type;

        if type == ItemType.Stackable:
            _set_int_property(item_def, KEY_STACK_SIZE, 1);
        elif type == ItemType.Weight:
            _set_int_property(item_def, KEY_STACK_SIZE, 1);
            _set_int_property(item_def, KEY_WEIGHT, 1);
        elif type == ItemType.Rect:
            _set_int_property(item_def, KEY_WIDTH, 1);
            _set_int_property(item_def, KEY_HEIGHT, 1);

        var id = item_def[KEY_ID];
        assert(!definitions.has(id), "Item definition ID '%s' already in use!" % id);
        definitions[id] = item_def;


func _set_int_property(item_def: Dictionary, property_name: String, default_value: int) -> void:
    if item_def.has(property_name):
        assert(item_def[property_name] is float, "'%s' property must be a number!" % property_name);

        # Convert the property from float to int
        item_def[property_name] = int(item_def[property_name]);
    else:
        item_def[property_name] = default_value;


func get(id: String) -> Dictionary:
    if definitions.has(id):
        return definitions[id];

    return {};
