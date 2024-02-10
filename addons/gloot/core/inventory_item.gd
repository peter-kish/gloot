@tool
@icon("res://addons/gloot/images/icon_item.svg")
extends Node
class_name InventoryItem

signal protoset_changed
signal prototype_id_changed
signal properties_changed
signal added_to_inventory(inventory)
signal removed_from_inventory(inventory)
signal equipped_in_slot(item_slot)
signal removed_from_slot(item_slot)

@export var protoset: ItemProtoset :
    set(new_protoset):
        if new_protoset == protoset:
            return

        if _inventory != null:
            return

        _disconnect_protoset_signals()
        protoset = new_protoset
        _connect_protoset_signals()

        # Reset the prototype ID (pick the first prototype from the protoset)
        if protoset && protoset._prototypes && protoset._prototypes.keys().size() > 0:
            prototype_id = protoset._prototypes.keys()[0]
        else:
            prototype_id = ""

        protoset_changed.emit()
        update_configuration_warnings()

@export var prototype_id: String :
    set(new_prototype_id):
        if new_prototype_id == prototype_id:
            return
        if protoset == null && !new_prototype_id.is_empty():
            return
        if (protoset != null) && (!protoset.has_prototype(new_prototype_id)):
            return
        prototype_id = new_prototype_id
        _reset_properties()
        update_configuration_warnings()
        prototype_id_changed.emit()

@export var properties: Dictionary :
    set(new_properties):
        properties = new_properties
        properties_changed.emit()
        update_configuration_warnings()

var _inventory: Inventory
var _item_slot: ItemSlot

const KEY_PROTOSET: String = "protoset"
const KEY_PROTOTYE_ID: String = "prototype_id"
const KEY_PROPERTIES: String = "properties"
const KEY_NODE_NAME: String = "node_name"
const KEY_TYPE: String = "type"
const KEY_VALUE: String = "value"

const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"

const Verify = preload("res://addons/gloot/core/verify.gd")

func _connect_protoset_signals() -> void:
    if protoset == null:
        return
    protoset.changed.connect(_on_protoset_changed)


func _disconnect_protoset_signals() -> void:
    if protoset == null:
        return
    protoset.changed.disconnect(_on_protoset_changed)


func _on_protoset_changed() -> void:
    update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
    if !protoset:
        return PackedStringArray()

    if !protoset.has_prototype(prototype_id):
        return PackedStringArray(["Undefined prototype '%s'. Check the item protoset!" % prototype_id])

    return PackedStringArray()


func _reset_properties() -> void:
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
        _on_parented(get_parent())
    elif what == NOTIFICATION_UNPARENTED:
        _on_unparented()


func _on_parented(parent: Node) -> void:
    if parent is Inventory:
        _on_added_to_inventory(parent as Inventory)
    else:
        _inventory = null

    if parent is ItemSlot:
        _link_to_slot(parent as ItemSlot)
    else:
        _unlink_from_slot()


func _on_added_to_inventory(inventory: Inventory) -> void:
    assert(inventory != null)
    _inventory = inventory
    if _inventory.item_protoset:
        protoset = _inventory.item_protoset
    
    added_to_inventory.emit(_inventory)
    _inventory._on_item_added(self)


func _on_unparented() -> void:
    if _inventory:
        _on_removed_from_inventory(_inventory)
    _inventory = null

    _unlink_from_slot()


func _on_removed_from_inventory(inventory: Inventory) -> void:
    if inventory:
        removed_from_inventory.emit(inventory)
        inventory._on_item_removed(self)


func _link_to_slot(item_slot: ItemSlot) -> void:
    _item_slot = item_slot
    _item_slot._on_item_added(self)
    equipped_in_slot.emit(item_slot)


func _unlink_from_slot() -> void:
    if _item_slot == null:
        return
    var temp_slot := _item_slot
    _item_slot = null
    temp_slot._on_item_removed()
    removed_from_slot.emit(temp_slot)


func get_inventory() -> Inventory:
    return _inventory


func get_property(property_name: String, default_value = null) -> Variant:
    # Note: The protoset editor still doesn't support arrays and dictionaries,
    # but those can still be added via JSON definitions or via code.
    if properties.has(property_name):
        var value = properties[property_name]
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value

    if protoset && protoset.prototype_has_property(prototype_id, property_name):
        var value = protoset.get_prototype_property(prototype_id, property_name, default_value)
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value

    return default_value


func set_property(property_name: String, value) -> void:
    var old_property = null
    if properties.has(property_name):
        old_property = properties[property_name]
    properties[property_name] = value
    if old_property != properties[property_name]:
        properties_changed.emit()


func clear_property(property_name: String) -> void:
    if properties.has(property_name):
        properties.erase(property_name)
        properties_changed.emit()


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
