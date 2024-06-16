@tool
@icon("res://addons/gloot/images/icon_item_ref_slot.svg")
class_name ItemRefSlot
extends "res://addons/gloot/core/item_slot_base.gd"

## Holds a reference to an inventory item.

signal inventory_changed

const Verify = preload("res://addons/gloot/core/verify.gd")
const KEY_ITEM_INDEX: String = "item_index"
const EMPTY_SLOT = -1

## Path to an [Inventory] node. Sets the [member inventory] property.
@export var inventory_path: NodePath :
    set(new_inv_path):
        if inventory_path == new_inv_path:
            return
        inventory_path = new_inv_path
        update_configuration_warnings()
        _set_inventory_from_path(inventory_path)

var _wr_item: WeakRef = weakref(null)
var _wr_inventory: WeakRef = weakref(null)
@export var _equipped_item: int = EMPTY_SLOT : set = _set_equipped_item_index
## Reference to an [Inventory] node.
var inventory: Inventory = null :
    get = _get_inventory, set = _set_inventory


func _get_configuration_warnings() -> PackedStringArray:
    if inventory_path.is_empty():
        return PackedStringArray([
                "Inventory path not set! Inventory path needs to point to an inventory node, so " +\
                "items from that inventory can be equipped in the slot."])
    return PackedStringArray()


func _set_equipped_item_index(new_value: int) -> void:
    _equipped_item = new_value
    equip_by_index(new_value)


func _ready() -> void:
    _set_inventory_from_path(inventory_path)
    equip_by_index(_equipped_item)


func _set_inventory_from_path(path: NodePath) -> bool:
    if path.is_empty():
        return false

    var node: Node = null

    if is_inside_tree():
        node = get_node_or_null(inventory_path)

    if node == null || !(node is Inventory):
        return false
    
    clear()
    _set_inventory(node)
    return true


func _set_inventory(inventory: Inventory) -> void:
    if inventory == _wr_inventory.get_ref():
        return

    if _get_inventory() != null:
        _disconnect_inventory_signals()

    clear()
    _wr_inventory = weakref(inventory)
    inventory_changed.emit()

    if _get_inventory() != null:
        _connect_inventory_signals()


func _connect_inventory_signals() -> void:
    if _get_inventory() == null:
        return

    if !_get_inventory().item_removed.is_connected(_on_item_removed):
        _get_inventory().item_removed.connect(_on_item_removed)


func _disconnect_inventory_signals() -> void:
    if _get_inventory() == null:
        return

    if _get_inventory().item_removed.is_connected(_on_item_removed):
        _get_inventory().item_removed.disconnect(_on_item_removed)


func _on_item_removed(item: InventoryItem) -> void:
    clear()


func _get_inventory() -> Inventory:
    return _wr_inventory.get_ref()

## Equips the given inventory item in the slot. If the slot already holds an
## item, [method clear] will be called first. Returns [code]false[/code] if the
## [method clear] call fails, the slot can't hold the given item, or already
## holds the given item. Returns [code]true[/code] otherwise.
func equip(item: InventoryItem) -> bool:
    if !can_hold_item(item):
        return false

    if _wr_item.get_ref() == item:
        return false

    if get_item() != null && !clear():
        return false

    _wr_item = weakref(item)
    _equipped_item = _get_inventory().get_item_index(item)
    item_equipped.emit()
    return true


func equip_by_index(index: int) -> bool:
    if _get_inventory() == null:
        return false
    if index < 0:
        return false
    if index >= _get_inventory().get_item_count():
        return false
    return equip(_get_inventory().get_items()[index])

## Clears the item slot.
func clear() -> bool:
    if get_item() == null:
        return false
        
    _wr_item = weakref(null)
    _equipped_item = EMPTY_SLOT
    cleared.emit()
    return true

## Returns the equipped item.
func get_item() -> InventoryItem:
    return _wr_item.get_ref()

## Checks if the slot can hold the given item, i.e. [member inventory] contains
## the given item and the item is not [code]null[/code]. This method can
## be overriden to implement item slots that can only hold specific items.
func can_hold_item(item: InventoryItem) -> bool:
    if item == null:
        return false

    if _get_inventory() == null || !_get_inventory().has_item(item):
        return false

    return true

## Clears the item slot.
func reset() -> void:
    clear()

## Serializes the item slot into a dictionary.
func serialize() -> Dictionary:
    var result: Dictionary = {}
    var item : InventoryItem = _wr_item.get_ref()

    if item != null && item.get_inventory() != null:
        result[KEY_ITEM_INDEX] = item.get_inventory().get_item_index(item)

    return result

## Loads the item slot data from the given dictionary.
## [br]
## [b]Note:[/b] [param inventory] must be set prior to the
## [method deserialize] call!
func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_ITEM_INDEX, [TYPE_INT, TYPE_FLOAT]):
        return false

    reset()

    if source.has(KEY_ITEM_INDEX):
        var item_index: int = source[KEY_ITEM_INDEX]
        if !_equip_item_with_index(item_index):
            return false

    return true


func _equip_item_with_index(item_index: int) -> bool:
    if _get_inventory() == null:
        return false
    if item_index >= _get_inventory().get_item_count():
        return false
    equip(_get_inventory().get_items()[item_index])
    return true

