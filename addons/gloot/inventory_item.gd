extends Node
class_name InventoryItem
tool

signal protoset_changed
signal prototype_id_changed
signal properties_changed

export(Resource) var protoset: Resource setget _set_prototset
export(String) var prototype_id: String setget _set_prototype_id
export(Dictionary) var properties: Dictionary setget _set_properties
var _inventory: Node
var _inventory_script = load("res://addons/gloot/inventory.gd")

const KEY_PROTOSET: String = "protoset"
const KEY_PROTOTYE_ID: String = "prototype_id"
const KEY_PROPERTIES: String = "properties"
const KEY_NODE_NAME: String = "node_name"
const KEY_TYPE: String = "type"
const KEY_VALUE: String = "value"

const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"

const Verify = preload("res://addons/gloot/verify.gd")


func _set_prototset(new_protoset: Resource) -> void:
    var old_protoset = protoset
    protoset = new_protoset
    if old_protoset != protoset:
        # Reset the prototype ID (pick the first prototype from the protoset)
        prototype_id = ""
        if protoset && protoset._prototypes && protoset._prototypes.keys().size() > 0:
            _set_prototype_id(protoset._prototypes.keys()[0])

        emit_signal("protoset_changed")


func _set_prototype_id(new_prototype_id: String) -> void:
    var old_prototype_id = prototype_id
    prototype_id = new_prototype_id
    if old_prototype_id != prototype_id:
        reset_properties()
        emit_signal("prototype_id_changed")


func _set_properties(new_properties: Dictionary) -> void:
    properties = new_properties
    emit_signal("properties_changed")


func reset_properties() -> void:
    if !protoset:
        properties = {}
        return

    # Reset (erase) all properties from the current prototype but preserve the rest
    var prototype: Dictionary = protoset.get(prototype_id)
    var keys: Array = properties.keys().duplicate()
    for property in keys:
        if prototype.has(property):
            properties.erase(property)


func _notification(what):
    if what == NOTIFICATION_PARENTED:
        if !(get_parent() is _inventory_script):
            _inventory = null
            return
        _inventory = get_parent()
        var inv_item_protoset = get_parent().get("item_protoset")
        if inv_item_protoset:
            protoset = inv_item_protoset
        _emit_added(get_parent())
    elif what == NOTIFICATION_UNPARENTED:
        _emit_removed(_inventory)
        _inventory = null


func _emit_removed(obj: Object):
    if obj && obj.has_signal("item_removed"):
        obj.emit_signal("item_removed", self)


func _emit_added(obj: Object):
    if obj && obj.has_signal("item_added"):
        obj.emit_signal("item_added", self)


func get_inventory() -> Node:
    return _inventory


func get_property(property_name: String, default_value = null):
    if properties.has(property_name):
        return properties[property_name]
    if protoset:
        return protoset.get_item_property(prototype_id, property_name, default_value)
    return default_value


func set_property(property_name: String, value) -> void:
    var old_property = null
    if properties.has(property_name):
        old_property = properties[property_name]
    properties[property_name] = value
    if old_property != properties[property_name]:
        emit_signal("properties_changed")


func clear_property(property_name: String) -> void:
    properties.erase(property_name)


func reset() -> void:
    protoset = null
    prototype_id = ""
    properties = {}


func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_NODE_NAME] = name
    result[KEY_PROTOSET] = protoset.resource_path
    result[KEY_PROTOTYE_ID] = prototype_id
    if !properties.empty():
        result[KEY_PROPERTIES] = {}
        for property_name in properties.keys():
            result[KEY_PROPERTIES][property_name] = _serialize_property(property_name)

    return result


func _serialize_property(property_name: String) -> Dictionary:
    # Store all properties as strings for JSON support.
    var result: Dictionary = {}
    var property_value = properties[property_name]
    var property_type = typeof(property_value)
    result = {
        KEY_TYPE: property_type,
        KEY_VALUE: var2str(property_value)
    }
    return result;


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOSET, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOTYE_ID, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()

    name = source[KEY_NODE_NAME]
    protoset = load(source[KEY_PROTOSET])
    prototype_id = source[KEY_PROTOTYE_ID]
    if source.has(KEY_PROPERTIES):
        for key in source[KEY_PROPERTIES].keys():
            properties[key] = _deserialize_property(source[KEY_PROPERTIES][key])
            if properties[key] == null:
                properties = {}
                return false

    return true


func _deserialize_property(data: Dictionary):
    # Properties are stored as strings for JSON support.
    var result = str2var(data[KEY_VALUE])
    var expected_type: int = data[KEY_TYPE]
    var property_type: int = typeof(result)
    if property_type != expected_type:
        print("Property has unexpected type: %s. Expected: %s" %
                    [Verify.type_names[property_type], Verify.type_names[expected_type]])
        return null
    return result


func get_texture() -> Texture:
    var texture_path = get_property(KEY_IMAGE)
    if texture_path && ResourceLoader.exists(texture_path):
        var texture = load(texture_path)
        if texture is Texture:
            return texture
    return null


func get_title() -> String:
    var title = get_property(KEY_NAME, prototype_id)
    if !(title is String):
        title = prototype_id

    return title
