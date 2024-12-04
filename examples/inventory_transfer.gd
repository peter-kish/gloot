extends Control


@onready var inventory_left: Inventory = $Inventory
@onready var inventory_right: Inventory = $Inventory2
@onready var btn_left_to_right: Button = $VBoxContainer/HBoxContainer2/BtnLToR
@onready var btn_right_to_left: Button = $VBoxContainer/HBoxContainer2/BtnRToL
@onready var btn_equip: Button = $VBoxContainer/HBoxContainer3/HBoxContainer/BtnEquipL
@onready var btn_unequip: Button = $VBoxContainer/HBoxContainer3/HBoxContainer/BtnUnequipL
@onready var ctrl_inventory_left: CtrlInventory = $VBoxContainer/HBoxContainer/CtrlInventory
@onready var ctrl_inventory_right: CtrlInventory = $VBoxContainer/HBoxContainer/CtrlInventory2
@onready var slot: ItemSlot = $ItemSlot


func _ready() -> void:
    btn_left_to_right.pressed.connect(_on_ltor_pressed)
    btn_right_to_left.pressed.connect(_on_rtol_pressed)
    btn_equip.pressed.connect(_on_equip_pressed)
    btn_unequip.pressed.connect(_on_unequip_pressed)


func _on_ltor_pressed() -> void:
    var selected_items: Array[InventoryItem] = ctrl_inventory_left.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        inventory_left.transfer(selected_item, inventory_right)


func _on_rtol_pressed() -> void:
    var selected_items: Array[InventoryItem] = ctrl_inventory_right.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        inventory_right.transfer(selected_item, inventory_left)


func _on_equip_pressed() -> void:
    if slot.get_item() != null:
        return
    var item: InventoryItem = ctrl_inventory_left.get_selected_inventory_item()
    if item == null:
        return

    slot.equip(item)


func _on_unequip_pressed() -> void:
    if slot.get_item() != null:
        inventory_left.add_item(slot.get_item())
        slot.clear()
