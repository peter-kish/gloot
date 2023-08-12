@tool
extends Node
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

        new_protoset.changed.connect(Callable(self, "_on_protoset_modified"))

        protoset = new_protoset
        protoset_changed.emit()
        update_configuration_warnings()

@export var prototype_id: String :
    get:
        return prototype_id
    set(new_prototype_id):
        if new_prototype_id == prototype_id:
            return
        reset_properties()
        prototype_id = new_prototype_id
        update_configuration_warnings()
        prototype_id_changed.emit()

@export var properties: Dictionary :
    get:
        return properties
    set(new_properties):
        properties = new_properties
        properties_changed.emit()
        update_configuration_warnings()

var _inventory: Node

const KEY_PROTOSET: String = "protoset"
const KEY_PROTOTYE_ID: String = "prototype_id"
const KEY_PROPERTIES: String = "properties"
const KEY_NODE_NAME: String = "node_name"
const KEY_TYPE: String = "type"
const KEY_VALUE: String = "value"

const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"

const Verify = preload("res://addons/gloot/core/verify.gd")


func _get_configuration_warnings() -> PackedStringArray:
    if !protoset:
        return PackedStringArray()

    if !protoset.has_prototype(prototype_id):
        return PackedStringArray(["Undefined prototype '%s'. Check the item protoset!" % prototype_id])

    return PackedStringArray()


func _on_protoset_modified() -> void:
    update_configuration_warnings()


func reset_properties() -> void:
    if !protoset || prototype_id.is_empty():
        properties = {}
        return

    # Reset (erase) all properties from the current prototype but preserve the rest
    var prototype: Dictionary = protoset.get_prototype(prototype_id)
    var keys: Array = properties.keys().duplicate()
    for property in keys:
        if prototype.has(property):
            properties.erase(property)


func _notification(what):
    if what == NOTIFICATION_PARENTED:
        if !(get_parent() is Inventory):
            _inventory = null
            return
        _inventory = get_parent()
        var inv_item_protoset = get_parent().get("item_protoset")
        if inv_item_protoset:
            protoset = inv_item_protoset
        _on_item_added(get_parent())
    elif what == NOTIFICATION_UNPARENTED:
        _on_item_removed(_inventory)
        _inventory = null


func _on_item_removed(obj: Object):
    if obj && obj.has_method("_on_item_removed"):
        obj._on_item_removed(self)


func _on_item_added(obj: Object):
    if obj && obj.has_method("_on_item_added"):
        obj._on_item_added(self)


func get_inventory() -> Node:
    return _inventory


func get_property(property_name: String, default_value = null) -> Variant:
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
        properties_changed.emit()


func clear_property(property_name: String) -> void:
    properties.erase(property_name)


func reset() -> void:
    protoset = null
    prototype_id = ""
    properties = {}


func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_NODE_NAME] = name as String
    result[KEY_PROTOSET] = protoset.resource_path
    result[KEY_PROTOTYE_ID] = prototype_id
    if !properties.is_empty():
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
        KEY_VALUE: var_to_str(property_value)
    }
    return result;


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOSET, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOTYE_ID, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()
    
    if !source[KEY_NODE_NAME].is_empty() && source[KEY_NODE_NAME] != name:
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
