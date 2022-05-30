extends Control


onready var inventory_left: InventoryStacked = $InventoryStackedLeft;
onready var inventory_right: InventoryStacked = $InventoryStackedRight;
onready var btn_left_to_right: Button = $VBoxContainer/HBoxContainer2/BtnLToR;
onready var btn_right_to_left: Button = $VBoxContainer/HBoxContainer2/BtnRToL;
onready var ctrl_inventory_left: CtrlInventoryStacked = $VBoxContainer/HBoxContainer/CtrlInventoryStackedLeft;
onready var ctrl_inventory_right: CtrlInventoryStacked = $VBoxContainer/HBoxContainer/CtrlInventoryStackedRight;


func _ready() -> void:
    btn_left_to_right.connect("pressed", self, "_on_ltor_pressed");
    btn_right_to_left.connect("pressed", self, "_on_rtol_pressed");


func _on_ltor_pressed() -> void:
    var items: Array = ctrl_inventory_left.get_selected_inventory_items();
    if items.empty():
        return;

    for item in items:
        inventory_left.transfer_autosplitmerge(item, inventory_right);


func _on_rtol_pressed() -> void:
    var items: Array = ctrl_inventory_right.get_selected_inventory_items();
    if items.empty():
        return;

    for item in items:
        inventory_right.transfer_autosplitmerge(item, inventory_left);
