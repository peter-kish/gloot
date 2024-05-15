@tool
@icon("res://addons/gloot/images/icon_item_slot.svg")
class_name ItemSlot
extends Node

signal prototree_json_changed
signal item_equipped
signal cleared

const Verify = preload("res://addons/gloot/core/verify.gd")
const KEY_ITEM: String = "item"

@export var prototree_json: JSON:
    set(new_prototree_json):
        if new_prototree_json == prototree_json:
            return
        if _item:
            _item = null
        prototree_json = new_prototree_json
        _prototree.deserialize(prototree_json)
        prototree_json_changed.emit()
        update_configuration_warnings()

var _prototree := ProtoTree.new()
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
    if get_item() == null:
        return false
        
    _item._item_slot = null
    _item = null
    cleared.emit()
    _update_serialized_format()
    return true


func get_item() -> InventoryItem:
    return _item


func can_hold_item(item: InventoryItem) -> bool:
    assert(prototree_json != null, "Item prototree not set!")
    if item == null:
        return false
    if prototree_json != item._prototree_json:
        return false

    return true


func reset() -> void:
    clear()


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

