@tool
@icon("res://addons/gloot/images/icon_item.svg")
extends Node
class_name InventoryItem

## Inventory item class.
##
## It is based on an item prototype from an [ItemProtoset] resource. Can hold
## additional properties.

## Emitted when the items protoset changes.
signal protoset_changed
## Emitted when the item prototype ID changes.
signal prototype_id_changed
## Emitted when the item properties change.
signal properties_changed
## Emitted when an item property has changed.
signal property_changed(property_name)
signal added_to_inventory(inventory)
signal removed_from_inventory(inventory)
signal equipped_in_slot(item_slot)
signal removed_from_slot(item_slot)

const Utils = preload("res://addons/gloot/core/utils.gd")

## An [ItemProtoset] resource containing item prototypes.
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
        update_configuration_warnings()

## ID of the prototype from [member protoset] this item is based on.
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

## Additional item properties.
@export var properties: Dictionary :
    set(new_properties):
        properties = new_properties
        properties_changed.emit()
        update_configuration_warnings()

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

## Returns the [Inventory] this item belongs to.
func get_inventory() -> Inventory:
    return _inventory

## Returns the [ItemSlot] this item is equipped in.
func get_item_slot() -> ItemSlot:
    return _item_slot

## Swaps the two given items contained in an [Inventory] or [ItemSlot].
## [br]
## [b]NOTE:[/b] In the current version only two items of the same
## size can be swapped.
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

## Returns the value of the property with the given name. In case the property
## can not be found, the default value is returned.
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

## Sets the property with the given name for this item.
func set_property(property_name: String, value) -> void:
    if properties.has(property_name) && properties[property_name] == value:
        return
    properties[property_name] = value
    property_changed.emit(property_name)
    properties_changed.emit()

## Clears the property with the given name for this item.
func clear_property(property_name: String) -> void:
    if properties.has(property_name):
        properties.erase(property_name)
        property_changed.emit(property_name)
        properties_changed.emit()

## Resets all properties to default values.
func reset() -> void:
    protoset = null
    prototype_id = ""
    properties = {}

## Serializes the item into a dictionary.
func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_NODE_NAME] = name as String
    result[KEY_PROTOSET] = Inventory._serialize_item_protoset(protoset)
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

## Deserializes the item from a given dictionary.
func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOSET, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOTYE_ID, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()
    
    if !source[KEY_NODE_NAME].is_empty() && source[KEY_NODE_NAME] != name:
        name = source[KEY_NODE_NAME]
    protoset = Inventory._deserialize_item_protoset(source[KEY_PROTOSET])
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
    var result = Utils.str_to_var(data[KEY_VALUE])
    var expected_type: int = data[KEY_TYPE]
    var property_type: int = typeof(result)
    if property_type != expected_type:
        print("Property has unexpected type: %s. Expected: %s" %
                    [Verify.type_names[property_type], Verify.type_names[expected_type]])
        return null
    return result

## Helper function for retrieving the item texture. It checks the
## [code]image[/code] item property and loads it as a texture, if available.
func get_texture() -> Texture2D:
    var texture_path = get_property(KEY_IMAGE)
    if texture_path && texture_path != "" && ResourceLoader.exists(texture_path):
        var texture = load(texture_path)
        if texture is Texture2D:
            return texture
    return null

## Helper function for retrieving the item title. It checks the [code]name[/code]
## item property and uses it as the title, if available. Otherwise,
## [code]prototype_id[/code] is returned as title.
func get_title() -> String:
    var title = get_property(KEY_NAME, prototype_id)
    if !(title is String):
        title = prototype_id

    return title
