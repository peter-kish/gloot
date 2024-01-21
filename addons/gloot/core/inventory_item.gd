@tool
@icon("res://addons/gloot/images/icon_item.svg")
extends RefCounted
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

        if (_inventory != null) && (new_protoset != _inventory.item_protoset):
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

@export var prototype_id: String :
    set(new_prototype_id):
        if new_prototype_id == prototype_id:
            return
        _reset_properties()
        prototype_id = new_prototype_id
        prototype_id_changed.emit()

@export var _properties: Dictionary

var _inventory: Inventory :
    set(new_inventory):
        if new_inventory == _inventory:
            return
        _inventory = new_inventory
        if _inventory:
            protoset = _inventory.item_protoset
var _item_slot: ItemSlot

const KEY_PROTOSET: String = "protoset"
const KEY_PROTOTYE_ID: String = "prototype_id"
const KEY_PROPERTIES: String = "properties"
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


static func swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    if item1 == null || item2 == null || item1 == item2:
        return false

    var owner1 = item1.get_inventory()
    if owner1 == null:
        owner1 = item1.get_item_slot()
    var owner2 = item2.get_inventory()
    if owner2 == null:
        owner2 = item2.get_item_slot()
    if owner1 == null || owner2 == null:
        return false

    if owner1 is Inventory:
        if !owner1._constraint_manager._on_pre_item_swap(item1, item2):
            return false
    if owner2 is Inventory && owner1 != owner2:
        if !owner2._constraint_manager._on_pre_item_swap(item1, item2):
            return false

    var idx1 = _remove_item_from_owner(item1, owner1)
    var idx2 = _remove_item_from_owner(item2, owner2)
    if !_add_item_to_owner(item1, owner2, idx2):
        _add_item_to_owner(item1, owner1, idx1)
        _add_item_to_owner(item2, owner2, idx2)
        return false
    if !_add_item_to_owner(item2, owner1, idx1):
        _add_item_to_owner(item1, owner1, idx1)
        _add_item_to_owner(item2, owner2, idx2)
        return false

    if owner1 is Inventory:
        owner1._constraint_manager._on_post_item_swap(item1, item2)
    if owner2 is Inventory && owner1 != owner2:
        owner2._constraint_manager._on_post_item_swap(item1, item2)

    return true;


static func _remove_item_from_owner(item: InventoryItem, item_owner) -> int:
    if item_owner is Inventory:
        var inventory := (item_owner as Inventory)
        var item_idx = inventory.get_item_index(item)
        inventory.remove_item(item)
        return item_idx
    
    # TODO: Consider removing/deprecating ItemSlot.remember_source_inventory
    var item_slot := (item_owner as ItemSlot)
    var temp_remember_source_inventory = item_slot.remember_source_inventory
    item_slot.remember_source_inventory = false
    item_slot.clear()
    item_slot.remember_source_inventory = temp_remember_source_inventory
    return 0


static func _add_item_to_owner(item: InventoryItem, item_owner, index: int) -> bool:
    if item_owner is Inventory:
        var inventory := (item_owner as Inventory)
        if inventory.add_item(item):
            inventory.move_item(inventory.get_item_index(item), index)
            return true
        return false
    return (item_owner as ItemSlot).equip(item)

    
func has_property(property_name: String) -> bool:
    if _properties.has(property_name):
        return true
    if protoset && protoset.has_item_property(prototype_id, property_name):
        return true
    return false


func get_property(property_name: String, default_value = null) -> Variant:
    # Note: The protoset editor still doesn't support arrays and dictionaries,
    # but those can still be added via JSON definitions or via code.
    if _properties.has(property_name):
        var value = _properties[property_name]
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value

    if protoset && protoset.has_item_property(prototype_id, property_name):
        var value = protoset.get_prototype_property(prototype_id, property_name, default_value)
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value
        
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
    if _properties.has(property_name):
        _properties.erase(property_name)
        properties_changed.emit()


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

    result[KEY_PROTOSET] = Inventory._serialize_item_protoset(protoset)
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
    
    protoset = Inventory._deserialize_item_protoset(source[KEY_PROTOSET])
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
