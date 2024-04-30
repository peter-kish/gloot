@tool
@icon("res://addons/gloot/images/icon_item.svg")
extends RefCounted
class_name InventoryItem

signal prototree_changed
signal prototype_path_changed
signal property_changed(property_name)

@export var prototree_json: JSON :
    set(new_prototree_json):
        if new_prototree_json == prototree_json:
            return

        if (_inventory != null) && (new_prototree_json != _inventory.prototree_json):
            return

        prototree_json = new_prototree_json
        _prototree.deserialize(prototree_json)

        # Reset the prototype ID (pick the first prototype from the prototree)
        var prototypes := _prototree.get_prototypes()
        if prototypes.size() > 0:
            prototype_path = "/%s" % prototypes[0].get_id()
        else:
            prototype_path = ""

        prototree_changed.emit()
        
var _prototree := ProtoTree.new()

@export var prototype_path: String :
    set(new_prototype_path):
        if PrototypePath.str_paths_equal(new_prototype_path, prototype_path):
            return
        if prototree_json == null && !new_prototype_path.is_empty():
            return
        if prototree_json != null && (!_prototree.has_prototype(new_prototype_path)):
            return
        _reset_properties()
        prototype_path = new_prototype_path
        if prototree_json != null:
            prototype_path = str(_prototree.get_prototype(prototype_path).get_path())
        prototype_path_changed.emit()

@export var _properties: Dictionary

var _inventory: Inventory :
    set(new_inventory):
        if new_inventory == _inventory:
            return
        _inventory = new_inventory
        if _inventory:
            prototree_json = _inventory.prototree_json
var _item_slot: ItemSlot

const KEY_PROTOTREE: String = "prototree"
const KEY_PROTOTYE_PATH: String = "prototype_path"
const KEY_PROPERTIES: String = "properties"
const KEY_TYPE: String = "type"
const KEY_VALUE: String = "value"

const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"

const Verify = preload("res://addons/gloot/core/verify.gd")


func get_prototree() -> ProtoTree:
    return _prototree


func get_prototype() -> Prototype:
    # TODO: Store the prototype instead of getting it on each call.
    if _prototree.is_empty():
        return null
    return _prototree.get_prototype(prototype_path)


func _reset_properties() -> void:
    if _prototree.is_empty() || prototype_path.is_empty():
        _properties = {}
        return

    for property in get_overridden_properties():
        _properties.erase(property)


func duplicate() -> InventoryItem:
    var result := InventoryItem.new()
    result.prototree_json = prototree_json
    result.prototype_path = prototype_path
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
    if _prototree.has_prototype_property(prototype_path, property_name):
        return true
    return false


func get_property(property_name: String, default_value = null) -> Variant:
    if _properties.has(property_name):
        var value = _properties[property_name]
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value

    if _prototree.has_prototype_property(prototype_path, property_name):
        var value = _prototree.get_prototype_property(prototype_path, property_name, default_value)
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value
        
    if _properties.has(property_name):
        return _properties[property_name]
    if _prototree.get_prototypes().is_empty():
        return _prototree.get_prototype_property(prototype_path, property_name, default_value)
    return default_value


func set_property(property_name: String, value) -> void:
    if get_property(property_name) == value:
        return

    if _prototree.has_prototype_property(prototype_path, property_name):
        if _prototree.get_prototype_property(prototype_path, property_name) == value && _properties.has(property_name):
            _properties.erase(property_name)
            property_changed.emit(property_name)
            return

    if value == null:
        if _properties.has(property_name):
            _properties.erase(property_name)
            property_changed.emit(property_name)
    else:
        _properties[property_name] = value
        property_changed.emit(property_name)


func clear_property(property_name: String) -> void:
    if _properties.has(property_name):
        _properties.erase(property_name)
        property_changed.emit(property_name)


func get_overridden_properties() -> Array:
    return _properties.keys().duplicate()


func get_properties() -> Array:
    return _properties.keys() + _prototree.root().get_prototype(prototype_path).keys()


func is_property_overridden(property_name) -> bool:
    return _properties.has(property_name)


func reset() -> void:
    prototree_json = null
    prototype_path = ""
    _properties = {}


func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_PROTOTREE] = Inventory._serialize_prototree_json(prototree_json)
    result[KEY_PROTOTYE_PATH] = prototype_path
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
    if !Verify.dict(source, true, KEY_PROTOTREE, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOTYE_PATH, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()
    
    prototree_json = Inventory._deserialize_prototree_json(source[KEY_PROTOTREE])
    prototype_path = source[KEY_PROTOTYE_PATH]
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
    var title = get_property(KEY_NAME, prototype_path)
    if !(title is String):
        title = _prototree.get_prototype(prototype_path).get_id()

    return title
