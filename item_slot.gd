extends Node
class_name ItemSlot

signal item_set;
signal item_cleared;
signal inventory_changed;


var inventory: Inventory setget _set_inventory;
var item: InventoryItem setget _set_item;


func _set_inventory(new_inv: Inventory) -> void:
    if inventory != null:
        inventory.disconnect("tree_exiting", self, "_on_inventory_tree_exiting");
        inventory.disconnect("item_removed", self, "_on_item_removed");

    if new_inv != inventory:
        _set_item(null);

    inventory = new_inv;
    if inventory != null:
        inventory.connect("tree_exiting", self, "_on_inventory_tree_exiting");
        inventory.connect("item_removed", self, "_on_item_removed");

    emit_signal("inventory_changed", inventory);


func _set_item(new_item: InventoryItem) -> void:
    assert(can_hold_item(new_item));
    if inventory == null:
        return;

    if new_item && !inventory.has_item(new_item):
        return;

    if item != null:
        item.disconnect("tree_exiting", self, "_on_item_tree_exiting");

    item = new_item;
    if item != null:
        item.connect("tree_exiting", self, "_on_item_tree_exiting");
        emit_signal("item_set", item);
    else:
        emit_signal("item_cleared");


func can_hold_item(new_item: InventoryItem) -> bool:
    if new_item == null:
        return true;
    if inventory == null:
        return false;
    if !inventory.has_item(new_item):
        return false;

    return true;


func _on_inventory_tree_exiting():
    inventory = null;
    _set_item(null);


func _on_item_removed(pItem: InventoryItem) -> void:
    if pItem == item:
        _set_item(null);


func _on_item_tree_exiting():
    _set_item(null);

