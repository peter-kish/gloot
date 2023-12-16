@tool
extends "res://addons/gloot/core/item_slot_base.gd"
class_name ItemOwningSlot

var item: InventoryItem :
    get:
        return item
    set(new_item):
        if new_item == item:
            return
        if new_item:
            # Bind item
            assert(can_hold_item(new_item), "ItemOwningSlot can't hold that item!")
            _disconnect_item_signals()
            _item_map.remove_item_from_slot(new_item)

            if new_item.get_inventory():
                new_item.get_inventory().remove_item(new_item)

            item = new_item
            _connect_item_signals()
            _item_map.map_item(item, self)
            item_set.emit(item)
        else:
            # Clear item
            _disconnect_item_signals()
            _item_map.unmap_item(item)

            item = null
            item_cleared.emit()


const KEY_ITEM: String = "item"
const Verify = preload("res://addons/gloot/core/verify.gd")


func _connect_item_signals() -> void:
    if !item:
        return

    if !item.predelete.is_connected(_on_item_predelete):
        item.predelete.connect(_on_item_predelete)
    if !item.added_to_inventory.is_connected(_on_item_added_to_inventory):
        item.added_to_inventory.connect(_on_item_added_to_inventory)


func _disconnect_item_signals() -> void:
    if !item:
        return

    if item.predelete.is_connected(_on_item_predelete):
        item.predelete.disconnect(_on_item_predelete)
    if item.added_to_inventory.is_connected(_on_item_added_to_inventory):
        item.added_to_inventory.disconnect(_on_item_added_to_inventory)


func can_hold_item(new_item: InventoryItem) -> bool:
    if new_item == null:
        return false

    return true


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

