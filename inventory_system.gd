tool
extends EditorPlugin


func _enter_tree():
    add_custom_type("InventoryItem", "Node", preload("inventory_item.gd"), null);
    add_custom_type("InventoryItemStackable", "Node", preload("inventory_item_stackable.gd"), null);
    add_custom_type("InventoryItemWeight", "Node", preload("inventory_item_weight.gd"), null);

    add_custom_type("Inventory", "Node", preload("inventory.gd"), null);
    add_custom_type("InventoryLimited", "Node", preload("inventory_limited.gd"), null);


func _exit_tree():
    remove_custom_type("InventoryItem");
    remove_custom_type("InventoryItemStackable");
    remove_custom_type("InventoryItemWeight");

    remove_custom_type("Inventory");
    remove_custom_type("InventoryLimited");
