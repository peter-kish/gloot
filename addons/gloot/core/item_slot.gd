@tool
@icon("res://addons/gloot/images/icon_item_slot.svg")
class_name ItemSlot
extends "res://addons/gloot/core/item_slot_base.gd"

signal protoset_changed

const Verify = preload("res://addons/gloot/core/verify.gd")
const KEY_ITEM: String = "item"

@export var item_protoset: ItemProtoset:
    set(new_item_protoset):
        if new_item_protoset == item_protoset:
            return
        if _item:
            _item = null
        item_protoset = new_item_protoset
        protoset_changed.emit()
        update_configuration_warnings()
@export var remember_source_inventory: bool = true

var _wr_source_inventory: WeakRef = weakref(null)
var _item: InventoryItem


func _get_configuration_warnings() -> PackedStringArray:
    if item_protoset == null:
        return PackedStringArray([
                "This item slot has no protoset. Set the 'item_protoset' field to be able to equip items."])
    return PackedStringArray()


func equip(item: InventoryItem) -> bool:
    if !can_hold_item(item):
        return false

    if item.get_parent() == self:
        return false

    if get_item() != null && !clear():
        return false

    _wr_source_inventory = weakref(item.get_inventory())

    if item.get_parent():
        item.get_parent().remove_child(item)

    add_child(item)
    if Engine.is_editor_hint():
        item.owner = get_tree().edited_scene_root
    return true


func _on_item_added(item: InventoryItem) -> void:
    _item = item
    item_equipped.emit()


func clear() -> bool:
    return _clear_impl(remember_source_inventory)


func _clear_impl(return_item: bool) -> bool:
    if get_item() == null:
        return false
        
    if return_item && _return_item_to_source_inventory():
        return true
        
    remove_child(get_item())
    return true


func _return_item_to_source_inventory() -> bool:
    var inventory: Inventory = (_wr_source_inventory.get_ref() as Inventory)
    if inventory != null:
        if inventory.add_item(get_item()):
            return true
    return false


func _on_item_removed() -> void:
    _item = null
    _wr_source_inventory = weakref(null)
    cleared.emit()


func get_item() -> InventoryItem:
    return _item


func can_hold_item(item: InventoryItem) -> bool:
    assert(item_protoset != null, "Item protoset not set!")
    if item == null:
        return false
    if item_protoset != item.protoset:
        return false

    return true


func reset() -> void:
    if _item:
        _item.queue_free()
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

