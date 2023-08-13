@tool
extends Node
class_name ItemSlot

signal item_set(item)
signal item_cleared
signal inventory_changed(inventory)


@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        update_configuration_warnings()
        var node: Node = get_node_or_null(inventory_path)

        if is_inside_tree() && node:
            assert(node is Inventory)
        
        if node == null:
            return
        
        self.inventory = node

@export var equipped_item: int = -1 :
    get:
        return equipped_item
    set(new_equipped_item):
        equipped_item = new_equipped_item
        if equipped_item < 0:
            self.item = null
            return
        if inventory:
            var items = inventory.get_items()
            if equipped_item < items.size() && can_hold_item(items[equipped_item]):
                self.item = items[equipped_item]

var _inventory
var inventory :
    get:
        if !_inventory && !inventory_path.is_empty():
            self._inventory = get_node_or_null(inventory_path)

        return _inventory
    set(new_inv):
        if new_inv == _inventory:
            return

        _disconnect_inventory_signals()
        self.item = null
        _inventory = new_inv
        _connect_inventory_signals()

        inventory_changed.emit(inventory)
        
var item: InventoryItem :
    get:
        return item
    set(new_item):
        assert(can_hold_item(new_item))
        if inventory == null:
            return

        if new_item && !inventory.has_item(new_item):
            return

        if item != null:
            item.tree_exiting.disconnect(Callable(self, "_on_item_tree_exiting"))

        item = new_item
        if item != null:
            item.tree_exiting.connect(Callable(self, "_on_item_tree_exiting"))
            item_set.emit(item)
        else:
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

    if !inventory.tree_exiting.is_connected(Callable(self, "_on_inventory_tree_exiting")):
        inventory.tree_exiting.connect(Callable(self, "_on_inventory_tree_exiting"))
    if !inventory.item_removed.is_connected(Callable(self, "_on_item_removed")):
        inventory.item_removed.connect(Callable(self, "_on_item_removed"))


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.tree_exiting.is_connected(Callable(self, "_on_inventory_tree_exiting")):
        inventory.tree_exiting.disconnect(Callable(self, "_on_inventory_tree_exiting"))
    if inventory.item_removed.is_connected(Callable(self, "_on_item_removed")):
        inventory.item_removed.disconnect(Callable(self, "_on_item_removed"))


func can_hold_item(new_item: InventoryItem) -> bool:
    if new_item == null:
        return true
    if inventory == null:
        return false
    if !inventory.has_item(new_item):
        return false

    return true


func _ready():
    self.inventory = get_node_or_null(inventory_path)
    if equipped_item >= 0 && inventory:
        var items = inventory.get_items()
        if equipped_item < items.size() && can_hold_item(items[equipped_item]):
            self.item = items[equipped_item]


func _on_inventory_tree_exiting():
    inventory = null
    self.item = null


func _on_item_removed(pItem: InventoryItem) -> void:
    if pItem == item:
        self.item = null


func _on_item_tree_exiting():
    self.item = null


func reset():
    self.inventory = null
    self.item = null


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

