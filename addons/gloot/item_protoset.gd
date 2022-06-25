class_name ItemProtoset
extends Resource
tool

const KEY_ID: String = "id"

export(String, MULTILINE) var json_data setget _set_json_data

var _prototypes: Dictionary = {}


func _set_json_data(new_json_data: String) -> void:
    json_data = new_json_data
    if !json_data.empty():
        parse(json_data)


func parse(json: String) -> void:
    _prototypes.clear()

    var parse_result = parse_json(json)
    assert(parse_result is Array, "JSON file must contain an array!")

    for prototype in parse_result:
        assert(prototype is Dictionary, "Item definition must be a dictionary!")
        assert(prototype.has(KEY_ID), "Item definition must have an '%s' property!" % KEY_ID)
        assert(prototype[KEY_ID] is String, "'%s' property must be a string!" % KEY_ID)

        var id = prototype[KEY_ID]
        assert(!_prototypes.has(id), "Item definition ID '%s' already in use!" % id)
        _prototypes[id] = prototype


func get(id: String) -> Dictionary:
    assert(has(id), "No prototype for ID %s" % id)
    return _prototypes[id]


func has(id: String) -> bool:
    return _prototypes.has(id)


func get_item_property(id: String, property_name: String, default_value = null):
    if has(id):
        var prototype = get(id)
        if !prototype.empty() && prototype.has(property_name):
            return prototype[property_name]
    
    return default_value
