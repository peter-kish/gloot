tool
extends EditorPlugin

# TODO: Item sprites
# TODO: Basic UI elements


func _enter_tree():
    add_custom_type("ItemProtoSet", "Resource", preload("item_protoset.gd"), preload("images/icon_item_protoset.svg"));

    add_custom_type("InventoryItem", "Node", preload("inventory_item.gd"), preload("images/icon_item.svg"));

    add_custom_type("Inventory", "Node", preload("inventory.gd"), preload("images/icon_inventory.svg"));
    add_custom_type("InventoryStacked", "Node", preload("inventory_stacked.gd"), preload("images/icon_inventory_stacked.svg"));
    add_custom_type("InventoryGrid", "Node", preload("inventory_grid.gd"), preload("images/icon_inventory_grid.svg"));

    add_custom_type("ItemSlot", "Node", preload("item_slot.gd"), preload("images/icon_item_slot.svg"));

    add_custom_type("CtrlInventory", "VBoxContainer", preload("ctrl_inventory.gd"), preload("images/icon_ctrl_inventory.svg"));
    add_custom_type("CtrlInventoryStacked", "VBoxContainer", preload("ctrl_inventory_stacked.gd"), preload("images/icon_ctrl_inventory_stacked.svg"));
    add_custom_type("CtrlInventoryGrid", "Container", preload("ctrl_inventory_grid.gd"), preload("images/icon_ctrl_inventory_grid.svg"));


func _exit_tree():
    remove_custom_type("ItemProtoSet");

    remove_custom_type("InventoryItem");

    remove_custom_type("Inventory");
    remove_custom_type("InventoryStacked");
    remove_custom_type("InventoryGrid");

    remove_custom_type("ItemSlot");

    remove_custom_type("CtrlInventory");
    remove_custom_type("CtrlInventoryStacked");
    remove_custom_type("CtrlInventoryGrid");
