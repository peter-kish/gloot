@tool
class_name ItemProtoset
extends Resource

const KEY_ID: String = "id"

@export_multiline var json_data :
    get:
        return json_data
    set(new_json_data):
        json_data = new_json_data
        if !json_data.is_empty():
            parse(json_data)
        _save()

var _prototypes: Dictionary = {} :
    get:
        return _prototypes
    set(new_prototypes):
        _prototypes = new_prototypes
        _update_json_data()
        _save()


func parse(json: String) -> void:
    _prototypes.clear()

    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json) == OK, "Failed to parse JSON!")
    var parse_result = test_json_conv.data
    assert(parse_result is Array, "JSON file must contain an array!")

    for prototype in parse_result:
        assert(prototype is Dictionary, "Item definition must be a dictionary!")
        assert(prototype.has(KEY_ID), "Item definition must have an '%s' property!" % KEY_ID)
        assert(prototype[KEY_ID] is String, "'%s' property must be a string!" % KEY_ID)

        var id = prototype[KEY_ID]
        assert(!_prototypes.has(id), "Item definition ID '%s' already in use!")
        _prototypes[id] = prototype
        _unstringify_prototype(_prototypes[id])


func _to_json() -> String:
    var result: Array[Dictionary]
    for prototype_id in _prototypes.keys():
        result.append(get_prototype(prototype_id))

    for prototype in result:
        _stringify_prototype(prototype)

    # TODO: Add plugin settings for this
    return JSON.stringify(result, "    ")


func _stringify_prototype(prototype: Dictionary) -> void:
    for key in prototype.keys():
        var type = typeof(prototype[key])
        if (type != TYPE_STRING) and (type != TYPE_FLOAT):
            prototype[key] = var_to_str(prototype[key])


func _unstringify_prototype(prototype: Dictionary) -> void:
    for key in prototype.keys():
        var type = typeof(prototype[key])
        if type == TYPE_STRING:
            var variant = str_to_var(prototype[key])
            if variant != null:
                prototype[key] = variant


func _update_json_data() -> void:
    json_data = _to_json()


func _save() -> void:
    emit_changed()
    if !resource_path.is_empty():
        ResourceSaver.save(self)


func get_prototype(id: StringName) -> Variant:
    assert(has_prototype(id), "No prototype")
    return _prototypes[id]


func add_prototype(id: String) -> void:
    assert(!has_prototype(id), "Prototype with ID already exists")
    _prototypes[id] = {KEY_ID: id}
    _update_json_data()
    _save()


func remove_prototype(id: String) -> void:
    assert(has_prototype(id), "No prototype for ID")
    _prototypes.erase(id)
    _update_json_data()
    _save()


func rename_prototype(id: String, new_id: String) -> void:
    assert(has_prototype(id), "No prototype for ID")
    assert(!has_prototype(new_id), "Prototype with ID already exists")
    add_prototype(new_id)
    _prototypes[new_id] = _prototypes[id].duplicate()
    _prototypes[new_id][KEY_ID] = new_id
    remove_prototype(id)
    _update_json_data()
    _save()


func set_prototype_properties(id: String, new_properties: Dictionary) -> void:
    _prototypes[id] = new_properties
    _update_json_data()
    _save()


func has_prototype(id: String) -> bool:
    return _prototypes.has(id)


func get_item_property(id: String, property_name: String, default_value = null) -> Variant:
    if has_prototype(id):
        var prototype = get_prototype(id)
        if !prototype.is_empty() && prototype.has(property_name):
            return prototype[property_name]
    
    return default_value
