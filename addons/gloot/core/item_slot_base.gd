extends Node

signal item_set
signal item_cleared

const ItemSlotBase = preload("res://addons/gloot/core/item_slot_base.gd")
const KEY_ITEM: String = "item"

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

            item = new_item
            _connect_item_signals()
            _item_map.map_item(item, self)
            item_set.emit()
        else:
            # Clear item
            _disconnect_item_signals()
            _item_map.unmap_item(item)

            item = null
            item_cleared.emit()


class _ItemMap:
    var _map: Dictionary


    func map_item(item: InventoryItem, slot: ItemSlotBase) -> void:
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


# Override this
func can_hold_item(new_item: InventoryItem) -> bool:
    return false


func _connect_item_signals() -> void:
    if !item:
        return

    if !item.predelete.is_connected(_on_item_predelete):
        item.predelete.connect(_on_item_predelete)


func _disconnect_item_signals() -> void:
    if !item:
        return

    if item.predelete.is_connected(_on_item_predelete):
        item.predelete.disconnect(_on_item_predelete)


# Override this
func _on_item_predelete():
    pass
