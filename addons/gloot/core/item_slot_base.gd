extends Node

signal item_set(item)
signal item_cleared

const ItemSlotBase = preload("res://addons/gloot/core/item_slot_base.gd")

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
