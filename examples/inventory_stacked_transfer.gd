extends Control


onready var inventory_left: InventoryStacked = $InventoryStackedLeft
onready var inventory_right: InventoryStacked = $InventoryStackedRight
onready var btn_left_to_right: Button = $VBoxContainer/HBoxContainer2/BtnLToR
onready var btn_right_to_left: Button = $VBoxContainer/HBoxContainer2/BtnRToL
onready var btn_equip: Button = $VBoxContainer/HBoxContainer3/BtnEquip
onready var btn_unequip: Button = $VBoxContainer/HBoxContainer3/BtnUnequip
onready var ctrl_inventory_left: CtrlInventoryStacked = $VBoxContainer/HBoxContainer/CtrlInventoryStackedLeft
onready var ctrl_inventory_right: CtrlInventoryStacked = $VBoxContainer/HBoxContainer/CtrlInventoryStackedRight
onready var slot: ItemSlot = $ItemSlot


func _ready() -> void:
    btn_left_to_right.connect("pressed", self, "_on_ltor_pressed")
    btn_right_to_left.connect("pressed", self, "_on_rtol_pressed")
    btn_equip.connect("pressed", self, "_on_equip_pressed")
    btn_unequip.connect("pressed", self, "_on_unequip_pressed")


func _on_ltor_pressed() -> void:
    var items: Array = ctrl_inventory_left.get_selected_inventory_items()
    if items.empty():
        return

    for item in items:
        inventory_left.transfer_autosplitmerge(item, inventory_right)


func _on_rtol_pressed() -> void:
    var items: Array = ctrl_inventory_right.get_selected_inventory_items()
    if items.empty():
        return

    for item in items:
        inventory_right.transfer_autosplitmerge(item, inventory_left)


func _on_equip_pressed() -> void:
    var items: Array = ctrl_inventory_left.get_selected_inventory_items()
    if items.empty():
        return

    slot.item = items[0]


func _on_unequip_pressed() -> void:
    slot.item = null
        
