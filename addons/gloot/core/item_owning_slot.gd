@tool
extends ItemSlotBase
class_name ItemOwningSlot

const Verify = preload("res://addons/gloot/core/verify.gd")


func _connect_item_signals() -> void:
    super._connect_item_signals()
    if !item:
        return

    if !item.added_to_inventory.is_connected(_on_item_added_to_inventory):
        item.added_to_inventory.connect(_on_item_added_to_inventory)


func _disconnect_item_signals() -> void:
    super._disconnect_item_signals()
    if !item:
        return

    if item.added_to_inventory.is_connected(_on_item_added_to_inventory):
        item.added_to_inventory.disconnect(_on_item_added_to_inventory)


func can_hold_item(new_item: InventoryItem) -> bool:
    if new_item == null:
        return false

    return true


func _on_item_set() -> void:
    if item.get_inventory() != null:
        item.get_inventory().remove_item(item)


func _on_item_predelete():
    item = null


func _on_item_added_to_inventory(inventory: Inventory):
    item = null


func reset():
    item = null


func serialize() -> Dictionary:
    var result: Dictionary = {}

    if item != null:
        result[KEY_ITEM] = item.serialize()

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_ITEM, [TYPE_DICTIONARY]):
        return false

    reset()

    if source.has(KEY_ITEM):
        var temp_item := InventoryItem.new()
        if !temp_item.deserialize(source[KEY_ITEM]):
            return false
        item = temp_item

    return true

