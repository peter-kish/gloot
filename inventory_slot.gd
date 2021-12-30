extends Node
class_name InventorySlot

signal item_bound;
signal cleared;
signal inventory_changed;


var inventory: Inventory setget _set_inventory;
var item: InventoryItem setget _set_item;


func _set_inventory(new_inv: Inventory) -> void:
    set_inventory(new_inv);


func _set_item(new_item: InventoryItem) -> void:
    assert(set_item(new_item));

    
func set_inventory(new_inv: Inventory) -> void:
    if inventory != null:
        inventory.disconnect("tree_exiting", self, "_on_inventory_tree_exiting");
        inventory.disconnect("item_removed", self, "_on_item_removed");

    if new_inv != inventory:
        set_item(null);

    inventory = new_inv;
    if inventory != null:
        inventory.connect("tree_exiting", self, "_on_inventory_tree_exiting");
        inventory.connect("item_removed", self, "_on_item_removed");

    emit_signal("inventory_changed", inventory);


func set_item(new_item: InventoryItem) -> bool:
    if inventory == null:
        return false;

    if new_item && !inventory.has_item(new_item):
        return false;

    if item != null:
        item.disconnect("tree_exiting", self, "_on_item_tree_exiting");

    item = new_item;
    if item != null:
        item.connect("tree_exiting", self, "_on_item_tree_exiting");
        emit_signal("item_bound", item);
    else:
        emit_signal("cleared");

    return true;


func _on_inventory_tree_exiting():
    inventory = null;
    set_item(null);


func _on_item_removed(pItem: InventoryItem) -> void:
    if pItem == item:
        set_item(null);


func _on_item_tree_exiting():
    set_item(null);

