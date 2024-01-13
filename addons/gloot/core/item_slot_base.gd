@tool
@icon("res://addons/gloot/images/icon_item_slot.svg")
class_name ItemSlotBase
extends Node

signal item_equipped
signal cleared


# Override this
func equip(item: InventoryItem) -> bool:
    return false


# Override this
func clear() -> bool:
    return false


# Override this
func get_item() -> InventoryItem:
    return null


# Override this
func can_hold_item(item: InventoryItem) -> bool:
    return false


# Override this
func reset() -> void:
    pass


# Override this
func serialize() -> Dictionary:
    return {}


# Override this
func deserialize(source: Dictionary) -> bool:
    return false