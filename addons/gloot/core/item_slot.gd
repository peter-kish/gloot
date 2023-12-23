@tool
class_name ItemSlot
extends Node

signal item_set
signal item_cleared

const Verify = preload("res://addons/gloot/core/verify.gd")
const KEY_ITEM: String = "item"

class _ItemMap:
    var _map: Dictionary


    func map_item(item: InventoryItem, slot: ItemSlot) -> void:
        if item == null || slot == null:
            return
        _map[item] = slot


    func unmap_item(item: InventoryItem) -> void:
        if item == null:
            return
        if _map.has(item):
            _map.erase(item)


    func remove_item_from_slot(item: InventoryItem) -> void:
        assert(item != null)
        if _map.has(item):
            _map[item].item = null
            unmap_item(item)


static var _item_map := _ItemMap.new()

var item: InventoryItem :
    get:
        return item
    set(new_item):
        if new_item == item:
            return
        if new_item:
            # Bind item
            assert(can_hold_item(new_item), "Item slot can't hold that item!")
            _disconnect_item_signals()
            _item_map.remove_item_from_slot(new_item)
            reset()

            if new_item.get_parent() != self && !new_item._busy_adding_removing:
                if new_item.get_parent():
                    new_item.get_parent().remove_child(new_item)
                add_child(new_item)

            item = new_item
            _connect_item_signals()
            _item_map.map_item(item, self)
            _on_item_set()
            item_set.emit()
        else:
            # Clear item
            _disconnect_item_signals()
            _item_map.unmap_item(item)

            if item.get_parent() == self && !item._busy_adding_removing:
                remove_child(item)

            item = null
            item_cleared.emit()


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

