@tool
@icon("res://addons/gloot/images/icon_item.svg")
extends RefCounted
class_name InventoryItem
## Stack-based inventory item class.
##
## It is based on an item prototype from an prototree. Can hold additional properties. The default stack size and 
## maximum stack size is 1, which can be changed by setting the `stack_size` and `maximum_stack_size` properties inside
## the prototype or directly inside the item.

signal property_changed(property_name)  ## Emitted when an item property has changed.

var _prototree_json: JSON :
    set(new_prototree_json):
        if new_prototree_json == _prototree_json:
            return

        if (_inventory != null) && (new_prototree_json != _inventory.prototree_json):
            return

        _disconnect_prototree_json_signals()
        _prototree_json = new_prototree_json
        _prototree.deserialize(_prototree_json)
        _on_prototree_changed()
        _connect_prototree_json_signals()
        
var _prototree := ProtoTree.new()
var _prototype: Prototype
var _properties: Dictionary

var _inventory: Inventory :
    set(new_inventory):
        if new_inventory == _inventory:
            return
        _inventory = new_inventory
        if _inventory:
            _prototree_json = _inventory.prototree_json

const KEY_PROTOTREE: String = "prototree"
const KEY_PROTOTYE_PATH: String = "prototype_path"
const KEY_PROPERTIES: String = "properties"
const KEY_TYPE: String = "type"
const KEY_VALUE: String = "value"

const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"

const Verify = preload("res://addons/gloot/core/verify.gd")
const Utils = preload("res://addons/gloot/core/utils.gd")


func _connect_prototree_json_signals() -> void:
    if !is_instance_valid(_prototree_json):
        return

    _prototree_json.changed.connect(_on_prototree_json_changed)


func _disconnect_prototree_json_signals() -> void:
    if !is_instance_valid(_prototree_json):
        return

    _prototree_json.changed.disconnect(_on_prototree_json_changed)


func _init(prototree_json: JSON = null, prototype_path: Variant = "") -> void:
    _prototree_json = prototree_json
    _prototype = _prototree.get_prototype(prototype_path)


func _on_prototree_json_changed() -> void:
    _prototree.deserialize(_prototree_json)
    _on_prototree_changed()


func _on_prototree_changed() -> void:
    if _prototree_json == null:
        _prototype = null
        return

    if _prototype == null:
        # Pick the first one from the prototree
        var prototypes := _prototree.get_prototypes()
        if prototypes.size() > 0:
            _prototype = prototypes[0]
        else:
            _prototype = null
        return

    _prototype = _prototree.get_prototype(_prototype.get_path())


## Returns the inventory prototree parsed from the prototree_json JSON resource.
func get_prototree() -> ProtoTree:
    return _prototree


## Returns the item prototype.
func get_prototype() -> Prototype:
    return _prototype


## Returns a duplicate of the item.
func duplicate() -> InventoryItem:
    var result := InventoryItem.new(_prototree_json, _prototype.get_path())
    result._properties = _properties.duplicate()
    return result


## Returns the `Inventory` this item belongs to, or `null` if it is not inside an inventory.
func get_inventory() -> Inventory:
    return _inventory


## Swaps the two given items. Returns `false` if the items cannot be swapped.
static func swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    if item1 == null || item2 == null || item1 == item2:
        return false

    var inv1 = item1.get_inventory()
    var inv2 = item2.get_inventory()
    if inv1 == null || inv2 == null:
        return false

    if !inv1._constraint_manager._on_pre_item_swap(item1, item2):
        return false
    if inv1 != inv2:
        if !inv2._constraint_manager._on_pre_item_swap(item1, item2):
            return false

    var idx1 = _remove_item_from_owner(item1, inv1)
    var idx2 = _remove_item_from_owner(item2, inv2)
    if !_add_item_to_inventory(item1, inv2, idx2):
        _add_item_to_inventory(item1, inv1, idx1)
        _add_item_to_inventory(item2, inv2, idx2)
        return false
    if !_add_item_to_inventory(item2, inv1, idx1):
        _add_item_to_inventory(item1, inv1, idx1)
        _add_item_to_inventory(item2, inv2, idx2)
        return false

    if inv1 is Inventory:
        inv1._constraint_manager._on_post_item_swap(item1, item2)
    if inv2 is Inventory && inv1 != inv2:
        inv2._constraint_manager._on_post_item_swap(item1, item2)

    return true;


static func _remove_item_from_owner(item: InventoryItem, item_owner) -> int:
    if item_owner is Inventory:
        var inventory := (item_owner as Inventory)
        var item_idx = inventory.get_item_index(item)
        inventory.remove_item(item)
        return item_idx
    
    (item_owner as ItemSlot).clear()
    return 0


static func _add_item_to_inventory(item: InventoryItem, inventory: Inventory, index: int) -> bool:
    if inventory.add_item(item):
        inventory.move_item(inventory.get_item_index(item), index)
        return true
    return false


## Checks if the item has the given property defined.
func has_property(property_name: String) -> bool:
    if _properties.has(property_name):
        return true
    if _prototype != null &&  _prototype.has_property(property_name):
        return true
    return false


## Returns the given item property. If the item does not define the item property, `default_value` is returned.
func get_property(property_name: String, default_value = null) -> Variant:
    if _properties.has(property_name):
        var value = _properties[property_name]
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value

    if _prototype != null && _prototype.has_property(property_name):
        var value = _prototype.get_property(property_name, default_value)
        if typeof(value) == TYPE_DICTIONARY || typeof(value) == TYPE_ARRAY:
            return value.duplicate()
        return value
        
    if _properties.has(property_name):
        return _properties[property_name]
    if _prototype != null && _prototree.get_prototypes().is_empty():
        return _prototype.get_property(property_name, default_value)
    return default_value


## Sets the given item property to the given value.
func set_property(property_name: String, value) -> void:
    if get_property(property_name) == value:
        return

    if _prototype != null && _prototype.has_property(property_name):
        if _prototype.get_property(property_name) == value && _properties.has(property_name):
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


## Clears (undefines) the given item property.
func clear_property(property_name: String) -> void:
    if _properties.has(property_name):
        _properties.erase(property_name)
        property_changed.emit(property_name)


## Returns an array of overridden item properties.
func get_overridden_properties() -> Array:
    return _properties.keys().duplicate()


## Returns an array of item properties.
func get_properties() -> Array:
    if _prototype != null:
        return _properties.keys() + _prototype.get_properties().keys()
    else:
        return _properties.keys()


## Checks if the item overrides the given property.
func is_property_overridden(property_name) -> bool:
    return _properties.has(property_name)


## Resets item data. Clears its properties and sets its prototree to `null`.
func reset() -> void:
    _prototree_json = null
    _properties = {}


## Serializes the item into a `Dictionary`.
func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_PROTOTREE] = Inventory._serialize_prototree_json(_prototree_json)
    if _prototype != null:
        result[KEY_PROTOTYE_PATH] = str(_prototype.get_path())
    else:
        result[KEY_PROTOTYE_PATH] = ""
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


## Loads the item data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_PROTOTREE, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOTYE_PATH, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()
    
    # TODO: Check return values
    _prototree_json = Inventory._deserialize_prototree_json(source[KEY_PROTOTREE])
    _prototype = _prototree.get_prototype(source[KEY_PROTOTYE_PATH])
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
    var result = Utils.str_to_var(data[KEY_VALUE])
    var expected_type: int = data[KEY_TYPE]
    var property_type: int = typeof(result)
    if property_type != expected_type:
        print("Property has unexpected type: %s. Expected: %s" %
                    [Verify.type_names[property_type], Verify.type_names[expected_type]])
        return null
    return result


## Helper function for retrieving the item texture. It checks the image item property and loads it as a texture, if
## available.
func get_texture() -> Texture2D:
    var texture_path = get_property(KEY_IMAGE)
    if texture_path && texture_path != "" && ResourceLoader.exists(texture_path):
        var texture = load(texture_path)
        if texture is Texture2D:
            return texture
    return null


## Helper function for retrieving the item title. It checks the name item property and uses it as the title, if
## available. Otherwise, prototype_id is returned as title.
func get_title() -> String:
    var title = get_property(KEY_NAME, null)
    if !(title is String):
        title = _prototype.get_id()

    return title
