extends Control


@onready var slot: ItemSlot = $ItemSlot


func _ready() -> void:
    %BtnLToR.pressed.connect(_on_ltor_pressed)
    %BtnRToL.pressed.connect(_on_rtol_pressed)
    %BtnEquipL.pressed.connect(_on_equip_pressed)
    %BtnUnequipL.pressed.connect(_on_unequip_pressed)


func _on_ltor_pressed() -> void:
    var selected_items: Array[InventoryItem] = %CtrlInventoryLeft.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        %InventoryRight.add_item(selected_item)


func _on_rtol_pressed() -> void:
    var selected_items: Array[InventoryItem] = %CtrlInventoryRight.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        %InventoryLeft.add_item(selected_item)


func _on_equip_pressed() -> void:
    if %ItemSlot.get_item() != null:
        return
    var item: InventoryItem = %CtrlInventoryLeft.get_selected_inventory_item()
    if item == null:
        return

    %ItemSlot.equip(item)


func _on_unequip_pressed() -> void:
    if %ItemSlot.get_item() != null:
        %InventoryLeft.add_item(%ItemSlot.get_item())
