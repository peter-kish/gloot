@tool
@icon("res://addons/gloot/images/icon_item.svg")
extends RefCounted
class_name InventoryItem

signal protoset_changed
signal prototype_id_changed
signal properties_changed

@export var protoset: Resource :
    get:
        return protoset
    set(new_protoset):
        if new_protoset == protoset:
            return

        # Reset the prototype ID (pick the first prototype from the protoset)
        prototype_id = ""
        if new_protoset && new_protoset._prototypes && new_protoset._prototypes.keys().size() > 0:
            self.prototype_id = new_protoset._prototypes.keys()[0]

        protoset = new_protoset
        protoset_changed.emit()

@export var prototype_id: String :
    get:
        return prototype_id
    set(new_prototype_id):
        if new_prototype_id == prototype_id:
            return
        _reset_properties()
        prototype_id = new_prototype_id
        prototype_id_changed.emit()

@export var _properties: Dictionary

var _inventory: Inventory
var _item_slot: ItemSlot

const KEY_PROTOSET: String = "protoset"
const KEY_PROTOTYE_ID: String = "prototype_id"
const KEY_PROPERTIES: String = "properties"
const KEY_TYPE: String = "type"
const KEY_VALUE: String = "value"

const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"

const Verify = preload("res://addons/gloot/core/verify.gd")


func _reset_properties() -> void:
    if !protoset || prototype_id.is_empty():
        _properties = {}
        return

    for property in get_overridden_properties():
        _properties.erase(property)


func duplicate() -> InventoryItem:
    var result := InventoryItem.new()
    result.protoset = protoset
    result.prototype_id = prototype_id
    result._properties = _properties.duplicate()
    return result


func get_inventory() -> Inventory:
    return _inventory


func get_item_slot() -> ItemSlot:
    return _item_slot


func has_property(property_name: String) -> bool:
    if _properties.has(property_name):
        return true
    if protoset && protoset.has_item_property(prototype_id, property_name):
        return true
    return false


func get_property(property_name: String, default_value = null) -> Variant:
    if _properties.has(property_name):
        return _properties[property_name]
    if protoset:
        return protoset.get_item_property(prototype_id, property_name, default_value)
    return default_value


func set_property(property_name: String, value) -> void:
    if get_property(property_name) == value:
        return

    if protoset && protoset.has_item_property(prototype_id, property_name):
        if protoset.get_item_property(prototype_id, property_name) == value && _properties.has(property_name):
            _properties.erase(property_name)
            properties_changed.emit(property_name)
            return

    if value == null:
        if _properties.has(property_name):
            _properties.erase(property_name)
            properties_changed.emit(property_name)
    else:
        _properties[property_name] = value
        properties_changed.emit(property_name)


func clear_property(property_name: String) -> void:
    _properties.erase(property_name)


func get_overridden_properties() -> Array:
    return _properties.keys().duplicate()


func get_properties() -> Array:
    return _properties.keys() + protoset.get_prototype(prototype_id).keys()


func is_property_overridden(property_name) -> bool:
    return _properties.has(property_name)


func reset() -> void:
    protoset = null
    prototype_id = ""
    _properties = {}


func serialize() -> Dictionary:
    var result: Dictionary = {}

    if protoset == null:
        result[KEY_PROTOSET] = ""
    else:
        result[KEY_PROTOSET] = protoset.resource_path
    result[KEY_PROTOTYE_ID] = prototype_id
    if !_properties.is_empty():
        result[KEY_PROPERTIES] = {}
        for property_name in _properties.keys():
            result[KEY_PROPERTIES][property_name] = _serialize_property(property_name)

    return result


func _serialize_property(property_name: String) -> Dictionary:
    # Store all properties as strings for JSON support.
    var result: Dictionary = {}
    var property_value = _properties[property_name]
    var property_type = typeof(property_value)
    result = {
        KEY_TYPE: property_type,
        KEY_VALUE: var_to_str(property_value)
    }
    return result;


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_PROTOSET, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOTYE_ID, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()
    
    protoset = load(source[KEY_PROTOSET])
    prototype_id = source[KEY_PROTOTYE_ID]
    if source.has(KEY_PROPERTIES):
        for key in source[KEY_PROPERTIES].keys():
            var value = _deserialize_property(source[KEY_PROPERTIES][key])
            set_property(key, value)
            if value == null:
                _properties = {}
                return false

    return true


func _deserialize_property(data: Dictionary):
    # Properties are stored as strings for JSON support.
    var result = str_to_var(data[KEY_VALUE])
    var expected_type: int = data[KEY_TYPE]
    var property_type: int = typeof(result)
    if property_type != expected_type:
        print("Property has unexpected type: %s. Expected: %s" %
                    [Verify.type_names[property_type], Verify.type_names[expected_type]])
        return null
    return result


func get_texture() -> Texture2D:
    var texture_path = get_property(KEY_IMAGE)
    if texture_path && texture_path != "" && ResourceLoader.exists(texture_path):
        var texture = load(texture_path)
        if texture is Texture2D:
            return texture
    return null


func get_title() -> String:
    var title = get_property(KEY_NAME, prototype_id)
    if !(title is String):
        title = prototype_id

    return title
