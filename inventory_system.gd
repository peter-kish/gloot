tool
extends EditorPlugin


func _enter_tree():
    add_custom_type("Inventory", "Node", preload("inventory.gd"), null);
    add_custom_type("InventoryItem", "Node", preload("inventory_item.gd"), null);


func _exit_tree():
    remove_custom_type("Inventory");
    remove_custom_type("InventoryItem");
