@tool
extends Node
class_name ItemSlot

signal item_set(item)
signal item_cleared
signal inventory_changed(inventory)

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

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        update_configuration_warnings()
        var node: Node = get_node_or_null(inventory_path)

        if is_inside_tree() && node:
            assert(node is Inventory)
        
        equipped_item = -1
        inventory = node

@export var equipped_item: int = -1 :
    get:
        return equipped_item
    set(new_equipped_item):
        equipped_item = new_equipped_item
        if equipped_item < 0:
            item = null
            return
        if inventory:
            var items = inventory.get_items()
            if equipped_item < items.size() && can_hold_item(items[equipped_item]):
                item = items[equipped_item]

var _inventory
var inventory :
    get:
        return _inventory
    set(new_inv):
        if new_inv == _inventory:
            return

        _disconnect_inventory_signals()
        item = null
        _inventory = new_inv
        _connect_inventory_signals()

        inventory_changed.emit(inventory)
        
var item: InventoryItem :
    get:
        return item
    set(new_item):
        if new_item:
            # Bind item
            assert(can_hold_item(new_item), "ItemSlot can't hold that item!")
            _disconnect_item_signals()
            _item_map.remove_item_from_slot(new_item)

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


const KEY_INVENTORY: String = "inventory"
const KEY_ITEM: String = "item"
const Verify = preload("res://addons/gloot/core/verify.gd")


func _get_configuration_warnings() -> PackedStringArray:
    if inventory_path.is_empty():
        return PackedStringArray([
                "Inventory path not set! Inventory path needs to point to an inventory node, so " +\
                "items from that inventory can be equipped in the slot."])
    return PackedStringArray()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    if !inventory.predelete.is_connected(_on_inventory_predelete):
        inventory.predelete.connect(_on_inventory_predelete)
    if !inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.connect(_on_item_removed)


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.predelete.is_connected(_on_inventory_predelete):
        inventory.predelete.disconnect(_on_inventory_predelete)
    if inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.disconnect(_on_item_removed)


func _connect_item_signals() -> void:
    if !item:
        return
    item.predelete.connect(_on_item_predelete)


func _disconnect_item_signals() -> void:
    if !item:
        return
    item.predelete.disconnect(_on_item_predelete)


func can_hold_item(new_item: InventoryItem) -> bool:
    if new_item == null:
        return true
    if inventory == null:
        return false
    if !inventory.has_item(new_item):
        return false

    return true


func _ready():
    inventory = get_node_or_null(inventory_path)
    if equipped_item >= 0 && inventory:
        var items = inventory.get_items()
        if equipped_item < items.size() && can_hold_item(items[equipped_item]):
            item = items[equipped_item]


func _on_inventory_predelete():
    inventory = null
    equipped_item = -1


func _on_item_removed(pItem: InventoryItem) -> void:
    if pItem == item:
        equipped_item = -1


func _on_item_predelete():
    equipped_item = -1


func reset():
    inventory = null
    equipped_item = -1


func serialize() -> Dictionary:
    var result: Dictionary = {}

    # TODO: Find a better way to serialize inventory and item references
    if inventory:
        result[KEY_INVENTORY] = inventory.get_instance_id()
    if item:
        result[KEY_ITEM] = item.get_instance_id()

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_INVENTORY, [TYPE_INT, TYPE_FLOAT]):
        return false
    if !Verify.dict(source, false, KEY_ITEM, [TYPE_INT, TYPE_FLOAT]):
        return false

    reset()

    if source.has(KEY_INVENTORY):
        inventory = instance_from_id(source[KEY_INVENTORY])
        if inventory == null:
            print("Warning: Node not found (%s)!" % source[KEY_INVENTORY])
            return false
    if source.has(KEY_ITEM):
        item = instance_from_id(source[KEY_ITEM])
        if item == null:
            print("Warning: Node not found (%s)!" % source[KEY_ITEM])
            return false

    return true

