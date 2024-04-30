@tool
@icon("res://addons/gloot/images/icon_item_slot.svg")
class_name ItemSlot
extends "res://addons/gloot/core/item_slot_base.gd"

signal prototree_changed

const Verify = preload("res://addons/gloot/core/verify.gd")
const KEY_ITEM: String = "item"

@export var prototree_json: JSON:
    set(new_prototree_json):
        if new_prototree_json == prototree_json:
            return
        if _item:
            _item = null
        prototree_json = new_prototree_json
        prototree_changed.emit()
        update_configuration_warnings()
@export var remember_source_inventory: bool = true

var _wr_source_inventory: WeakRef = weakref(null)
var _item: InventoryItem :
    set(new_item):
        _item = new_item
var _serialized_format: Dictionary = {} :
    set(new_serialized_format):
        _serialized_format = new_serialized_format


func _get_property_list():
    return [
        {
            "name": "_serialized_format",
            "type": TYPE_DICTIONARY,
            "usage": PROPERTY_USAGE_STORAGE
        },
    ]


func _update_serialized_format() -> void:
    if Engine.is_editor_hint():
        _serialized_format = serialize()


func _ready() -> void:
    if !_serialized_format.is_empty():
        deserialize(_serialized_format)


func _get_configuration_warnings() -> PackedStringArray:
    if prototree_json == null:
        return PackedStringArray([
                "This item slot has no prototree. Set the 'prototree_json' field to be able to equip items."])
    return PackedStringArray()


func equip(item: InventoryItem) -> bool:
    if !can_hold_item(item):
        return false

    if get_item() != null && !clear():
        return false

    _wr_source_inventory = weakref(item.get_inventory())

    if item.get_item_slot() != null:
        item.get_item_slot().clear()
    if item.get_inventory() != null:
        item.get_inventory().remove_item(item)

    _item = item
    _item._item_slot = self
    item_equipped.emit()
    _update_serialized_format()
    return true


func clear() -> bool:
    return _clear_impl(remember_source_inventory)


func _clear_impl(return_item: bool) -> bool:
    if get_item() == null:
        return false
        
    var temp_item = _item
    _item._item_slot = null
    _item = null
    if return_item:
        _return_item_to_source_inventory(temp_item)
    _wr_source_inventory = weakref(null)
    cleared.emit()
    _update_serialized_format()
    return true


func _return_item_to_source_inventory(item: InventoryItem) -> bool:
    var inventory: Inventory = (_wr_source_inventory.get_ref() as Inventory)
    if inventory != null:
        if inventory.add_item(item):
            return true
    return false


func get_item() -> InventoryItem:
    return _item


func can_hold_item(item: InventoryItem) -> bool:
    assert(prototree_json != null, "Item prototree not set!")
    if item == null:
        return false
    if prototree_json != item.prototree_json:
        return false

    return true


func reset() -> void:
    _clear_impl(false)


func serialize() -> Dictionary:
    var result: Dictionary = {}

    if _item != null:
        result[KEY_ITEM] = _item.serialize()

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_ITEM, [TYPE_DICTIONARY]):
        return false

    reset()

    if source.has(KEY_ITEM):
        var item := InventoryItem.new()
        if !item.deserialize(source[KEY_ITEM]):
            return false
        equip(item)

    return true

