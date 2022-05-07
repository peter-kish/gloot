tool
extends EditorPlugin

# TODO: Item description files


func _enter_tree():
    add_custom_type("InventoryItem", "Node", preload("inventory_item.gd"), preload("icon_item.svg"));
    add_custom_type("InventoryItemStackable", "Node", preload("inventory_item_stackable.gd"), preload("icon_item_stackable.svg"));
    add_custom_type("InventoryItemWeight", "Node", preload("inventory_item_weight.gd"), preload("icon_item_weight.svg"));
    add_custom_type("InventoryItemRect", "Node", preload("inventory_item_rect.gd"), preload("icon_item_rect.svg"));

    add_custom_type("Inventory", "Node", preload("inventory.gd"), preload("icon_inventory.svg"));
    add_custom_type("InventoryLimited", "Node", preload("inventory_limited.gd"), preload("icon_inventory_limited.svg"));
    add_custom_type("InventoryGrid", "Node", preload("inventory_grid.gd"), preload("icon_inventory_grid.svg"));

    add_custom_type("ItemSlot", "Node", preload("item_slot.gd"), null);


func _exit_tree():
    remove_custom_type("InventoryItem");
    remove_custom_type("InventoryItemStackable");
    remove_custom_type("InventoryItemWeight");
    remove_custom_type("InventoryItemRect");

    remove_custom_type("Inventory");
    remove_custom_type("InventoryLimited");
    remove_custom_type("InventoryGrid");

    remove_custom_type("ItemSlot");
