@tool
@icon("res://addons/gloot/images/icon_item_slot.svg")
class_name ItemSlot
extends Node
## An item slot that can hold an inventory item.
##
## An item slot that can hold an inventory item.

signal protoset_changed ## Emitted when the protoset property has been changed.
signal item_equipped ## Emitted when an item is placed in the slot.
signal cleared(item: InventoryItem) ## Emitted when the slot is cleared.Emitted when the slot is cleared.

const _Verify = preload("res://addons/gloot/core/verify.gd")
const _KEY_ITEM: String = "item"

## A JSON resource containing prototype information.
@export var protoset: JSON:
    set(new_protoset):
        if new_protoset == protoset:
            return
        protoset = new_protoset
        if is_instance_valid(_inventory):
            _inventory.protoset = protoset
        protoset_changed.emit()
        update_configuration_warnings()
var _inventory: Inventory = null:
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
    _inventory.protoset = protoset
    var item_count_constraint := ItemCountConstraint.new()
    _inventory.add_child(item_count_constraint)
    add_child(_inventory)


func _on_item_added(item: InventoryItem) -> void:
    item_equipped.emit()


func _on_item_removed(item: InventoryItem) -> void:
    cleared.emit(item)


func _get_configuration_warnings() -> PackedStringArray:
    if protoset == null:
        return PackedStringArray([
                "This item slot has no protoset. Set the 'protoset' field to be able to equip items."])
    return PackedStringArray()


## Equips the given inventory item in the slot. If the slot already contains an item, clear() will be called first.
## Returns false if the clear call fails, the slot can't hold the given item, or already holds the given item. Returns
## true otherwise.
func equip(item: InventoryItem) -> bool:
    if !can_hold_item(item):
        return false

    if get_item() != null && !clear():
        return false

    if item.get_inventory() != null:
        item.get_inventory().remove_item(item)

    _inventory.add_item(item)
    return true


## Clears the item slot. Returns false if there's no item in the slot.
func clear() -> bool:
    if get_item() == null:
        return false
        
    _inventory.clear()
    return true


## Returns the equipped item or `null` if there's no item in the slot.
func get_item() -> InventoryItem:
    if _inventory.get_item_count() == 0:
        return null
    return _inventory.get_items()[0]


## Checks if the slot can hold the given item, i.e. the slot uses the same protoset as the item and the item is not
## `null`.
func can_hold_item(item: InventoryItem) -> bool:
    assert(protoset != null, "Item protoset not set!")
    if item == null:
        return false
    if protoset != item.protoset:
        return false

    return true


## Serializes the item slot into a `Dictionary`.
func serialize() -> Dictionary:
    var result: Dictionary = {}

    if get_item() != null:
        result[_KEY_ITEM] = get_item().serialize()

    return result


## Loads the item slot data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    if !_Verify.dict(source, false, _KEY_ITEM, [TYPE_DICTIONARY]):
        return false

    clear()

    if source.has(_KEY_ITEM):
        var item := InventoryItem.new()
        if !item.deserialize(source[_KEY_ITEM]):
            return false
        equip(item)

    return true
