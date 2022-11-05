extends Node
class_name ItemSlot
tool

signal item_set
signal item_cleared
signal inventory_changed


export(NodePath) var inventory_path: NodePath setget _set_inventory_path
export(int) var equipped_item: int = -1 setget _set_equipped_item
var inventory: Inventory setget _set_inventory, _get_inventory
var item: InventoryItem setget _set_item

const KEY_INVENTORY: String = "inventory"
const KEY_ITEM: String = "item"
const Verify = preload("res://addons/gloot/verify.gd")


func _set_inventory_path(new_inv_path: NodePath) -> void:
    inventory_path = new_inv_path
    var node: Node = get_node_or_null(inventory_path)

    if is_inside_tree() && node:
        assert(node is Inventory)
        
    _set_inventory(node)


func _set_equipped_item(new_equipped_item: int) -> void:
    equipped_item = new_equipped_item
    if equipped_item < 0:
        _set_item(null)
        return
    if inventory:
        var items = inventory.get_items()
        if equipped_item < items.size() && can_hold_item(items[equipped_item]):
            _set_item(items[equipped_item])


func _set_inventory(new_inv: Inventory) -> void:
    if new_inv == inventory:
        return

    _disconnect_inventory_signals()
    _set_item(null)
    inventory = new_inv
    _connect_inventory_signals()

    emit_signal("inventory_changed", inventory)


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    if !inventory.is_connected("tree_exiting", self, "_on_inventory_tree_exiting"):
        inventory.connect("tree_exiting", self, "_on_inventory_tree_exiting")
    if !inventory.is_connected("item_removed", self, "_on_item_removed"):
        inventory.connect("item_removed", self, "_on_item_removed")


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.is_connected("tree_exiting", self, "_on_inventory_tree_exiting"):
        inventory.disconnect("tree_exiting", self, "_on_inventory_tree_exiting")
    if inventory.is_connected("item_removed", self, "_on_item_removed"):
        inventory.disconnect("item_removed", self, "_on_item_removed")


func _get_inventory() -> Inventory:
    if !inventory && !inventory_path.is_empty():
        _set_inventory(get_node_or_null(inventory_path))

    return inventory


func _set_item(new_item: InventoryItem) -> void:
    assert(can_hold_item(new_item))
    if inventory == null:
        return

    if new_item && !inventory.has_item(new_item):
        return

    if item != null:
        item.disconnect("tree_exiting", self, "_on_item_tree_exiting")

    item = new_item
    if item != null:
        item.connect("tree_exiting", self, "_on_item_tree_exiting")
        emit_signal("item_set", item)
    else:
        emit_signal("item_cleared")


func can_hold_item(new_item: InventoryItem) -> bool:
    if new_item == null:
        return true
    if inventory == null:
        return false
    if !inventory.has_item(new_item):
        return false

    return true


func _ready():
    _set_inventory(get_node_or_null(inventory_path))
    if equipped_item >= 0 && inventory:
        var items = inventory.get_items()
        if equipped_item < items.size() && can_hold_item(items[equipped_item]):
            _set_item(items[equipped_item])


func _on_inventory_tree_exiting():
    inventory = null
    _set_item(null)


func _on_item_removed(pItem: InventoryItem) -> void:
    if pItem == item:
        _set_item(null)


func _on_item_tree_exiting():
    _set_item(null)


func reset():
    _set_inventory(null)
    _set_item(null)


func serialize() -> Dictionary:
    var result: Dictionary = {}

    if inventory:
        result[KEY_INVENTORY] = inventory.get_path()
    if item:
        result[KEY_ITEM] = item.get_path()

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_INVENTORY, [TYPE_NODE_PATH, TYPE_STRING]):
        return false
    if !Verify.dict(source, false, KEY_ITEM, [TYPE_NODE_PATH, TYPE_STRING]):
        return false

    reset()

    if source.has(KEY_INVENTORY):
        _set_inventory(get_node_or_null(source[KEY_INVENTORY]))
        if inventory == null:
            print("Warning: Node not found (%s)!" % source[KEY_INVENTORY])
            return false
    if source.has(KEY_ITEM):
        _set_item(get_node_or_null(source[KEY_ITEM]))
        if item == null:
            print("Warning: Node not found (%s)!" % source[KEY_ITEM])
            return false

    return true

