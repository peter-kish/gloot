@tool
@icon("res://addons/gloot/images/icon_item_slot.svg")
class_name ItemSlotBase
extends Node

## Base class for [ItemSlot] and [ItemRefSlot]

## Emitted when an item is placed in the slot.
signal item_equipped
## Emitted when the slot is cleared.
signal cleared


## Equips the given inventory item in the slot. See the documentation
## for [ItemSlot] and [ItemRefSlot] for more details.
func equip(item: InventoryItem) -> bool:
    return false


## Clears the item slot. See the documentation for [ItemSlot] and [ItemRefSlot]
## for more details.
func clear() -> bool:
    return false


## Returns the equipped item. See the documentation for [ItemSlot] and
## [ItemRefSlot] for more details.
func get_item() -> InventoryItem:
    return null


## Checks if the slot can hold the given item. See the documentation for [ItemSlot]
## and [ItemRefSlot] for more details.
func can_hold_item(item: InventoryItem) -> bool:
    return false


## Clears the item slot. See the documentation for [ItemSlot] and [ItemRefSlot]
## for more details.
func reset() -> void:
    pass


## Serializes the item slot into a dictionary. See the documentation for
## [ItemSlot] and [ItemRefSlot] for more details.
func serialize() -> Dictionary:
    return {}


## Loads the item slot data from the given dictionary. See the documentation
## for [ItemSlot] and [ItemRefSlot] for more details.
func deserialize(source: Dictionary) -> bool:
    return false
