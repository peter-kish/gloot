@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
    add_custom_type("ItemProtoset", "Resource", preload("core/item_protoset.gd"), preload("images/icon_item_protoset.svg"))

    add_custom_type("InventoryItem", "Node", preload("core/inventory_item.gd"), preload("images/icon_item.svg"))

    add_custom_type("Inventory", "Node", preload("core/inventory.gd"), preload("images/icon_inventory.svg"))
    add_custom_type("InventoryStacked", "Node", preload("core/inventory_stacked.gd"), preload("images/icon_inventory_stacked.svg"))
    add_custom_type("InventoryGrid", "Node", preload("core/inventory_grid.gd"), preload("images/icon_inventory_grid.svg"))
    add_custom_type("InventoryGridStacked", "Node", preload("core/inventory_grid_stacked.gd"), preload("images/icon_inventory_grid_stacked.svg"))

    add_custom_type("ItemSlot", "Node", preload("core/item_slot.gd"), preload("images/icon_item_slot.svg"))

    add_custom_type("CtrlInventory", "Control", preload("ui/ctrl_inventory.gd"), preload("images/icon_ctrl_inventory.svg"))
    add_custom_type("CtrlInventoryStacked", "Control", preload("ui/ctrl_inventory_stacked.gd"), preload("images/icon_ctrl_inventory_stacked.svg"))
    add_custom_type("CtrlInventoryGrid", "Control", preload("ui/ctrl_inventory_grid.gd"), preload("images/icon_ctrl_inventory_grid.svg"))
    add_custom_type("CtrlInventoryGridEx", "Control", preload("ui/ctrl_inventory_grid_ex.gd"), preload("images/icon_ctrl_inventory_grid.svg"))
    add_custom_type("CtrlItemSlot", "Control", preload("ui/ctrl_item_slot.gd"), preload("images/icon_ctrl_item_slot.svg"))
    add_custom_type("CtrlItemSlotEx", "Control", preload("ui/ctrl_item_slot_ex.gd"), preload("images/icon_ctrl_item_slot.svg"))

    inspector_plugin = preload("res://addons/gloot/editor/inventory_inspector_plugin.gd").new()
    inspector_plugin.editor_interface = get_editor_interface()
    inspector_plugin.undo_redo_manager = get_undo_redo()
    add_inspector_plugin(inspector_plugin)

    add_autoload_singleton("GLoot", "res://addons/gloot/gloot_autoload.gd")

    _add_settings()


func _exit_tree() -> void:
    remove_autoload_singleton("GLoot")

    remove_inspector_plugin(inspector_plugin)

    remove_custom_type("ItemProtoset")

    remove_custom_type("InventoryItem")

    remove_custom_type("Inventory")
    remove_custom_type("InventoryStacked")
    remove_custom_type("InventoryGrid")
    remove_custom_type("InventoryGridStacked")

    remove_custom_type("ItemSlot")

    remove_custom_type("CtrlInventory")
    remove_custom_type("CtrlInventoryStacked")
    remove_custom_type("CtrlInventoryGrid")
    remove_custom_type("CtrlInventoryGridEx")
    remove_custom_type("CtrlItemSlot")
    remove_custom_type("CtrlItemSlotEx")
    

func _add_settings() -> void:
    _add_setting("gloot/inspector_control_height", TYPE_INT, 200)


func _add_setting(name: String, type: int, value) -> void:
    if !ProjectSettings.has_setting(name):
        ProjectSettings.set(name, value)

    var property_info = {
        "name": name,
        "type": type
    }
    ProjectSettings.add_property_info(property_info)
    ProjectSettings.set_initial_value(name, value)
