@tool
@icon("res://addons/gloot/images/icon_item_protoset.svg")
class_name ItemProtoset
extends Resource

## A resource type holding a set of inventory item prototypes in JSON format.

const Utils = preload("res://addons/gloot/core/utils.gd")

const KEY_ID: String = "id"

## JSON string containing item prototypes.
@export_multiline var json_data: String :
    set(new_json_data):
        json_data = new_json_data
        if !json_data.is_empty():
            parse(json_data)
        _save()

var _prototypes: Dictionary = {} :
    set(new_prototypes):
        _prototypes = new_prototypes
        _update_json_data()
        _save()

## Parses the given json string and generates a new [code]prototypes[/code]
## dictionary.
func parse(json: String) -> void:
    _prototypes.clear()

    var test_json_conv: JSON = JSON.new()
    var parse_status = test_json_conv.parse(json)
    assert(parse_status == OK, "Failed to parse JSON!")
    var parse_result = test_json_conv.data
    assert(parse_result is Array, "JSON file must contain an array!")

    for prototype in parse_result:
        assert(prototype is Dictionary, "Item prototype must be a dictionary!")
        assert(prototype.has(KEY_ID), "Item prototype must have an '%s' property!" % KEY_ID)
        assert(prototype[KEY_ID] is String, "'%s' property must be a string!" % KEY_ID)

        var id = prototype[KEY_ID]
        assert(!_prototypes.has(id), "Item prototype ID '%s' already in use!" % id)
        _prototypes[id] = prototype
        _unstringify_prototype(_prototypes[id])


func _to_json() -> String:
    var result: Array[Dictionary]
    for prototype_id in _prototypes.keys():
        result.append(get_prototype(prototype_id))

    for prototype in result:
        _stringify_prototype(prototype)

    var indent = "\t"
    if ProjectSettings.get_setting("gloot/JSON_serialization/indent_using_spaces", true):
        indent = ""
        for i in ProjectSettings.get_setting("gloot/JSON_serialization/indent_size", 4):
            indent += " "
    
    return JSON.stringify(
        result,
        indent,
        ProjectSettings.get_setting("gloot/JSON_serialization/sort_keys", true),
        ProjectSettings.get_setting("gloot/JSON_serialization/full_precision", false),
    )


func _stringify_prototype(prototype: Dictionary) -> void:
    for key in prototype.keys():
        var type = typeof(prototype[key])
        if (type != TYPE_STRING) and (type != TYPE_FLOAT):
            prototype[key] = var_to_str(prototype[key])


func _unstringify_prototype(prototype: Dictionary) -> void:
    for key in prototype.keys():
        var type = typeof(prototype[key])
        if type == TYPE_STRING:
            var variant = Utils.str_to_var(prototype[key])
            if variant != null:
                prototype[key] = variant


func _update_json_data() -> void:
    json_data = _to_json()


func _save() -> void:
    if !Engine.is_editor_hint():
        return
    emit_changed()
    if !resource_path.is_empty():
        ResourceSaver.save(self)

## Returns the prototype with the given ID.
func get_prototype(id: StringName) -> Variant:
    assert(has_prototype(id), "No prototype with ID: %s" % id)
    return _prototypes[id]

## Adds a prototype with the given ID.
func add_prototype(id: String) -> void:
    assert(!has_prototype(id), "Prototype with ID already exists")
    _prototypes[id] = {KEY_ID: id}
    _update_json_data()
    _save()

## Removes the prototype with the given ID.
func remove_prototype(id: String) -> void:
    assert(has_prototype(id), "No prototype with ID: %s" % id)
    _prototypes.erase(id)
    _update_json_data()
    _save()

## Duplicates the prototype with the given ID.
func duplicate_prototype(id: String) -> void:
    assert(has_prototype(id), "No prototype with ID: %s" % id)
    var new_id = "%s_duplicate" % id
    var new_dict = _prototypes[id].duplicate()
    new_dict[KEY_ID] = new_id
    _prototypes[new_id] = new_dict
    _update_json_data()
    _save()

## Renames the prototype with the given ID to a new ID.
func rename_prototype(id: String, new_id: String) -> void:
    assert(has_prototype(id), "No prototype with ID: %s" % id)
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

## Checks if a prototype with the given ID exists.
func has_prototype(id: String) -> bool:
    return _prototypes.has(id)

## Sets the property with the given value for the prototype with the
## given ID.
func set_prototype_property(id: String, property_name: String, value) -> void:
    assert(has_prototype(id), "No prototype with ID: %s" % id)
    var prototype = get_prototype(id)
    prototype[property_name] = value

## Returns the value of the property with the given name from the prototype
## with the given ID. In case the value can not be found, the default value
## is returned.
func get_prototype_property(id: String, property_name: String, default_value = null) -> Variant:
    if has_prototype(id):
        var prototype = get_prototype(id)
        if !prototype.is_empty() && prototype.has(property_name):
            return prototype[property_name]
    
    return default_value

## Checks if the given prototype has the given property.
func prototype_has_property(id: String, property_name: String) -> bool:
    if has_prototype(id):
        return get_prototype(id).has(property_name)
    
    return false
