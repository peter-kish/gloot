@tool
@icon("res://addons/gloot/images/icon_item.svg")
extends RefCounted
class_name InventoryItem
## Stack-based inventory item class.
##
## It is based on an item prototype from an prototree. Can hold additional properties. The default stack size and 
## maximum stack size is 1, which can be changed by setting the `stack_size` and `maximum_stack_size` properties inside
## the prototype or directly inside the item.

const _StackManager = preload("res://addons/gloot/core/stack_manager.gd")
const _Verify = preload("res://addons/gloot/core/verify.gd")
const _Utils = preload("res://addons/gloot/core/utils.gd")
const _ItemCount = preload("res://addons/gloot/core/item_count.gd")
const _ProtoTreeCache = preload("res://addons/gloot/core/prototree/proto_tree_cache.gd")

signal property_changed(property_name: String) ## Emitted when an item property has changed.

## A JSON resource containing prototype information.
var protoset: JSON:
    set(new_protoset):
        if new_protoset == protoset:
            return

        if (_inventory != null) && (new_protoset != _inventory.protoset):
            return

        _disconnect_protoset_signals()
        protoset = new_protoset
        _prototree = _ProtoTreeCache.get_cached(protoset)
        _on_prototree_changed()
        _connect_protoset_signals()
        
var _prototree: ProtoTree = _ProtoTreeCache.get_empty()
var _prototype: Prototype = null
var _properties: Dictionary

var _inventory: Inventory:
    set(new_inventory):
        if new_inventory == _inventory:
            return
        _inventory = new_inventory
        if _inventory:
            protoset = _inventory.protoset

const _KEY_PROTOSET: String = "protoset"
const _KEY_PROTOTYPE_ID: String = "prototype_id"
const _KEY_PROPERTIES: String = "properties"
const _KEY_TYPE: String = "type"
const _KEY_VALUE: String = "value"

const _KEY_IMAGE: String = "image"
const _KEY_NAME: String = "name"


func _connect_protoset_signals() -> void:
    if !is_instance_valid(protoset):
        return

    protoset.changed.connect(_on_protoset_changed)


func _disconnect_protoset_signals() -> void:
    if !is_instance_valid(protoset):
        return

    protoset.changed.disconnect(_on_protoset_changed)


func _init(protoset_: JSON = null, prototype_id: String = "") -> void:
    protoset = protoset_
    if _prototree.has_prototype(prototype_id):
        _prototype = _prototree.get_prototype(prototype_id)


func _on_protoset_changed() -> void:
    _prototree.deserialize(protoset)
    _on_prototree_changed()


func _on_prototree_changed() -> void:
    if protoset == null:
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

    _prototype = _prototree.get_prototype(_prototype.get_prototype_id())


## Returns the inventory prototree parsed from the protoset JSON resource.
func get_prototree() -> ProtoTree:
    return _prototree


## Returns the item prototype.
func get_prototype() -> Prototype:
    return _prototype


## Returns a duplicate of the item.
func duplicate() -> InventoryItem:
    var result := InventoryItem.new(protoset, _prototype.get_prototype_id())
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

    var idx1 = inv1.get_item_index(item1)
    var idx2 = inv2.get_item_index(item2)
    inv1.remove_item(item1)
    inv2.remove_item(item2)

    if !inv2.add_item(item1):
        inv1.add_item(item1)
        inv1.move_item(inv1.get_item_index(item1), idx1)
        inv2.add_item(item2)
        inv2.move_item(inv2.get_item_index(item2), idx2)
        return false
    if !inv1.add_item(item2):
        inv1.add_item(item1)
        inv1.move_item(inv1.get_item_index(item1), idx1)
        inv2.add_item(item2)
        inv2.move_item(inv2.get_item_index(item2), idx2)
        return false
    inv2.move_item(inv2.get_item_index(item1), idx2)
    inv1.move_item(inv1.get_item_index(item2), idx1)

    if inv1 is Inventory:
        inv1._constraint_manager._on_post_item_swap(item1, item2)
    if inv2 is Inventory && inv1 != inv2:
        inv2._constraint_manager._on_post_item_swap(item1, item2)

    return true;


static func _add_item_to_inventory(item: InventoryItem, inventory: Inventory, index: int) -> bool:
    if inventory.add_item(item):
        inventory.move_item(inventory.get_item_index(item), index)
        return true
    return false


## Checks if the item has the given property.
func has_property(property_name: String) -> bool:
    if _properties.has(property_name):
        return true
    if _prototype != null && _prototype.has_property(property_name):
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


## Clears (un-defines) the given item property.
func clear_property(property_name: String) -> void:
    if _properties.has(property_name):
        _properties.erase(property_name)
        property_changed.emit(property_name)


## Returns an array of properties that the item overrides.
func get_overridden_properties() -> Array:
    return _properties.keys().duplicate()


## Returns an array of item properties (includes prototype properties).
func get_properties() -> Array:
    if _prototype != null:
        return _Utils.array_union(_properties.keys(), _prototype.get_properties().keys())
    else:
        return _properties.keys()


## Checks if the item overrides the given property.
func is_property_overridden(property_name) -> bool:
    return _properties.has(property_name)


## Resets item data. Clears its properties and sets its protoset to `null`.
func reset() -> void:
    protoset = null
    _properties = {}


## Serializes the item into a `Dictionary`.
func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[_KEY_PROTOSET] = Inventory._serialize_protoset(protoset)
    if _prototype != null:
        result[_KEY_PROTOTYPE_ID] = str(_prototype.get_prototype_id())
    else:
        result[_KEY_PROTOTYPE_ID] = ""
    if !_properties.is_empty():
        result[_KEY_PROPERTIES] = {}
        for property_name in _properties.keys():
            result[_KEY_PROPERTIES][property_name] = _serialize_property(property_name)

    return result


func _serialize_property(property_name: String) -> Dictionary:
    # Store all properties as strings for JSON support.
    var result: Dictionary = {}
    var property_value = _properties[property_name]
    var property_type = typeof(property_value)
    result = {
        _KEY_TYPE: property_type,
        _KEY_VALUE: var_to_str(property_value)
    }
    return result;


## Loads the item data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    if !_Verify.dict(source, true, _KEY_PROTOSET, TYPE_STRING) || \
        !_Verify.dict(source, true, _KEY_PROTOTYPE_ID, TYPE_STRING) || \
        !_Verify.dict(source, false, _KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()
    
    # TODO: Check return values
    protoset = _Utils._deserialize_protoset(source[_KEY_PROTOSET])
    _prototype = _prototree.get_prototype(source[_KEY_PROTOTYPE_ID])
    if source.has(_KEY_PROPERTIES):
        for key in source[_KEY_PROPERTIES].keys():
            var value = _deserialize_property(source[_KEY_PROPERTIES][key])
            set_property(key, value)
            if value == null:
                _properties = {}
                return false

    return true


func _deserialize_property(data: Dictionary):
    # Properties are stored as strings for JSON support.
    var result = _Utils.str_to_var(data[_KEY_VALUE])
    var expected_type: int = data[_KEY_TYPE]
    var property_type: int = typeof(result)
    if property_type != expected_type:
        print("Property has unexpected type: %s. Expected: %s" %
                    [_Verify.type_names[property_type], _Verify.type_names[expected_type]])
        return null
    return result


## Helper function for retrieving the item texture. It checks the image item property and loads it as a texture, if
## available.
func get_texture() -> Texture2D:
    var texture_path = get_property(_KEY_IMAGE)
    if texture_path && texture_path != "" && ResourceLoader.exists(texture_path):
        var texture = load(texture_path)
        if texture is Texture2D:
            return texture
    return null


## Helper function for retrieving the item title. It checks the name item property and uses it as the title, if
## available. Otherwise, prototype_id is returned as title.
func get_title() -> String:
    var title = get_property(_KEY_NAME, null)
    if title is String:
        return title
    if is_instance_valid(_prototype):
        return _prototype.get_prototype_id()
    return ""


## Returns the stack size.
func get_stack_size() -> int:
    return _StackManager.get_item_stack_size(self).count


## Returns the maximum stack size.
func get_max_stack_size() -> int:
    return _StackManager.get_item_max_stack_size(self).count


## Sets the stack size.
func set_stack_size(stack_size: int) -> bool:
    return _StackManager.set_item_stack_size(self, _ItemCount.new(stack_size))


## Sets the maximum stack size.
func set_max_stack_size(max_stack_size: int) -> void:
    _StackManager.set_item_max_stack_size(self, _ItemCount.new(max_stack_size))


## Merges the item stack into the `item_dst` stack. If `item_dst` doesn't have enough stack space and `split` is set to
## `true`, the stack will be split and only partially merged. Returns `false` if the merge cannot be performed.
func merge_into(item_dst: InventoryItem, split: bool = false) -> bool:
    return _StackManager.merge_stacks(item_dst, self, split)


## Checks if the item stack can be merged into `item_dst` with, or without splitting (`split` parameter).
func can_merge_into(item_dst: InventoryItem, split: bool = false) -> bool:
    return _StackManager.can_merge_stacks(item_dst, self, split)


## Checks if the item stack is compatible for merging with `item_dst`.
func compatible_with(item_dst: InventoryItem) -> bool:
    return _StackManager.stacks_compatible(self, item_dst)


## Returns the free stack space in the item stack (maximum_stack_size - stack_size).
func get_free_stack_space() -> int:
    return _StackManager.get_free_stack_space(self).count


## Splits the item stack into two and returns a reference to the new stack. `new_stack_size` defines the size of the new
## stack. Returns `null` if the split cannot be performed.
func split(new_stack_size: int) -> InventoryItem:
    return _StackManager.split_stack(self, _ItemCount.new(new_stack_size))


## Checks if the item stack can be split using the given new stack size.
func can_split(new_stack_size: int) -> bool:
    return _StackManager.can_split_stack(self, _ItemCount.new(new_stack_size))
