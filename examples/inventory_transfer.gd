extends Control


onready var inventory_left: Inventory = $Inventory
onready var inventory_right: Inventory = $Inventory2
onready var btn_left_to_right: Button = $VBoxContainer/HBoxContainer2/BtnLToR
onready var btn_right_to_left: Button = $VBoxContainer/HBoxContainer2/BtnRToL
onready var btn_equip_left: Button = $VBoxContainer/HBoxContainer3/HBoxContainer/BtnEquipL
onready var btn_unequip_left: Button = $VBoxContainer/HBoxContainer3/HBoxContainer/BtnUnequipL
onready var btn_equip_right: Button = $VBoxContainer/HBoxContainer3/HBoxContainer2/BtnEquipR
onready var btn_unequip_right: Button = $VBoxContainer/HBoxContainer3/HBoxContainer2/BtnUnequipR
onready var ctrl_inventory_left: CtrlInventory = $VBoxContainer/HBoxContainer/CtrlInventory
onready var ctrl_inventory_right: CtrlInventory = $VBoxContainer/HBoxContainer/CtrlInventory2
onready var slot_left: ItemSlot = $ItemSlot
onready var slot_right: ItemSlot = $ItemSlot2


func _ready() -> void:
    btn_left_to_right.connect("pressed", self, "_on_ltor_pressed")
    btn_right_to_left.connect("pressed", self, "_on_rtol_pressed")
    btn_equip_left.connect("pressed", self, "_on_equip_pressed", [slot_left, ctrl_inventory_left])
    btn_unequip_left.connect("pressed", self, "_on_unequip_pressed", [slot_left])
    btn_equip_right.connect("pressed", self, "_on_equip_pressed", [slot_right, ctrl_inventory_right])
    btn_unequip_right.connect("pressed", self, "_on_unequip_pressed", [slot_right])


func _on_ltor_pressed() -> void:
    var items: Array = ctrl_inventory_left.get_selected_inventory_items()
    if items.empty():
        return

    for item in items:
        inventory_left.transfer(item, inventory_right)


func _on_rtol_pressed() -> void:
    var items: Array = ctrl_inventory_right.get_selected_inventory_items()
    if items.empty():
        return

    for item in items:
        inventory_right.transfer(item, inventory_left)


func _on_equip_pressed(slot: ItemSlot, ctrl_inventory: CtrlInventory) -> void:
    var items: Array = ctrl_inventory.get_selected_inventory_items()
    if items.empty():
        return

    slot.item = items[0]


func _on_unequip_pressed(slot: ItemSlot) -> void:
    slot.item = null
