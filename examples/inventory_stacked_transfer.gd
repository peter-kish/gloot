extends Control

const StackManager = preload("res://addons/gloot/core/stack_manager.gd")

func _ready() -> void:
    %BtnLToR.pressed.connect(_on_ltor_pressed)
    %BtnRToL.pressed.connect(_on_rtol_pressed)
    %BtnEquip.pressed.connect(_on_equip_pressed)
    %BtnUnequip.pressed.connect(_on_unequip_pressed)
    assert(is_instance_valid(%InventoryRight))
    assert(is_instance_valid(%InventoryLeft))


func _on_ltor_pressed() -> void:
    var selected_items: Array[InventoryItem] = %GlootInventoryLeft.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        StackManager.inv_add_autosplitmerge(%InventoryRight, selected_item)


func _on_rtol_pressed() -> void:
    var selected_items: Array[InventoryItem] = %GlootInventoryRight.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        StackManager.inv_add_autosplitmerge(%InventoryLeft, selected_item)


func _on_equip_pressed() -> void:
    if %ItemSlot.get_item() != null:
        return
    var item: InventoryItem = %GlootInventoryLeft.get_selected_inventory_item()
    if item == null:
        return

    %ItemSlot.equip(item)


func _on_unequip_pressed() -> void:
    if %ItemSlot.get_item() != null && %InventoryLeft.can_add_item(%ItemSlot.get_item()):
        StackManager.inv_add_automerge(%InventoryLeft, %ItemSlot.get_item())
        
