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
        prototree_json = new_prototree_json
        if is_instance_valid(_inventory):
            _inventory.prototree_json = prototree_json
        prototree_json_changed.emit()
        update_configuration_warnings()
var _inventory: Inventory = null :
    set(new_inventory):
        if new_inventory == _inventory:
            return
        _disconnect_inventory_signals()
        _inventory = new_inventory
        _connect_inventory_signals()

    
func _connect_inventory_signals() -> void:
    if !is_instance_valid(_inventory):
        return
    _inventory.item_added.connect(_on_item_added)
    _inventory.item_removed.connect(_on_item_removed)


func _disconnect_inventory_signals() -> void:
    if !is_instance_valid(_inventory):
        return
    _inventory.item_added.disconnect(_on_item_added)
    _inventory.item_removed.disconnect(_on_item_removed)


func _init() -> void:
    _inventory = Inventory.new()
    _inventory.prototree_json = prototree_json
    var item_count_constraint := ItemCountConstraint.new()
    _inventory.add_child(item_count_constraint)
    add_child(_inventory)


func _on_item_added(item: InventoryItem) -> void:
    item_equipped.emit()


func _on_item_removed(item: InventoryItem) -> void:
    cleared.emit()


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

    if item.get_inventory() != null:
        item.get_inventory().remove_item(item)

    _inventory.add_item(item)
    return true


func clear() -> bool:
    if get_item() == null:
        return false
        
    _inventory.clear()
    return true


func get_item() -> InventoryItem:
    if _inventory.get_item_count() == 0:
        return null
    return _inventory.get_items()[0]


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

    if get_item() != null:
        result[KEY_ITEM] = get_item().serialize()

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

