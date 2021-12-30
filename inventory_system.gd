tool
extends EditorPlugin


func _enter_tree():
    add_custom_type("InventoryItem", "Node", preload("inventory_item.gd"), null);
    add_custom_type("InventoryItemStackable", "Node", preload("inventory_item_stackable.gd"), null);
    add_custom_type("InventoryItemWeight", "Node", preload("inventory_item_weight.gd"), null);
    add_custom_type("InventoryItemRect", "Node", preload("inventory_item_rect.gd"), null);

    add_custom_type("Inventory", "Node", preload("inventory.gd"), null);
    add_custom_type("InventoryLimited", "Node", preload("inventory_limited.gd"), null);
    add_custom_type("InventoryGrid", "Node", preload("inventory_grid.gd"), null);

    add_custom_type("InventorySlot", "Node", preload("inventory_slot.gd"), null);


func _exit_tree():
    remove_custom_type("InventoryItem");
    remove_custom_type("InventoryItemStackable");
    remove_custom_type("InventoryItemWeight");
    remove_custom_type("InventoryItemRect");

    remove_custom_type("Inventory");
    remove_custom_type("InventoryLimited");
    remove_custom_type("InventoryGrid");

    remove_custom_type("InventorySlot");
