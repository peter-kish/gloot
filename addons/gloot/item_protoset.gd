class_name ItemProtoset
extends Resource
tool

const KEY_ID: String = "id"

export(String, MULTILINE) var json_data setget _set_json_data

var _prototypes: Dictionary = {} setget _set_prototypes


func _set_json_data(new_json_data: String) -> void:
    json_data = new_json_data
    if !json_data.empty():
        parse(json_data)
    emit_changed()


func _set_prototypes(new_prototypes: Dictionary) -> void:
    _prototypes = new_prototypes
    update_json_data()
    emit_changed()


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


func _to_json() -> String:
    var result: Array
    for prototype_id in _prototypes.keys():
        result.append(get(prototype_id))

    # TODO: Add plugin settings for this
    return JSON.print(result, "    ")


func update_json_data() -> void:
    json_data = _to_json()
    emit_changed()


func get(id: String) -> Dictionary:
    assert(has(id), "No prototype for ID %s" % id)
    return _prototypes[id]


func add(id: String) -> void:
    assert(!has(id), "Prototype with ID already exists: %s" % id)
    _prototypes[id] = {KEY_ID: id}
    emit_changed()


func remove(id: String) -> void:
    assert(has(id), "No prototype for ID %s" % id)
    _prototypes.erase(id)
    emit_changed()


func rename(id: String, new_id: String) -> void:
    assert(has(id), "No prototype for ID %s" % id)
    assert(!has(new_id), "Prototype with ID already exists: %s" % new_id)
    add(new_id)
    _prototypes[new_id] = _prototypes[id].duplicate()
    _prototypes[new_id][KEY_ID] = new_id
    remove(id)
    emit_changed()


func has(id: String) -> bool:
    return _prototypes.has(id)


func get_item_property(id: String, property_name: String, default_value = null):
    if has(id):
        var prototype = get(id)
        if !prototype.empty() && prototype.has(property_name):
            return prototype[property_name]
    
    return default_value
