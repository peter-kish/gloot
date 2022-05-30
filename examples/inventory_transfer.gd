extends Control


onready var inventory_left: Inventory = $Inventory;
onready var inventory_right: Inventory = $Inventory2;
onready var btn_left_to_right: Button = $VBoxContainer/HBoxContainer2/BtnLToR;
onready var btn_right_to_left: Button = $VBoxContainer/HBoxContainer2/BtnRToL;
onready var ctrl_inventory_left: CtrlInventory = $VBoxContainer/HBoxContainer/CtrlInventory;
onready var ctrl_inventory_right: CtrlInventory = $VBoxContainer/HBoxContainer/CtrlInventory2;


func _ready() -> void:
    btn_left_to_right.connect("pressed", self, "_on_ltor_pressed");
    btn_right_to_left.connect("pressed", self, "_on_rtol_pressed");


func _on_ltor_pressed() -> void:
    var items: Array = ctrl_inventory_left.get_selected_inventory_items();
    if items.empty():
        return;

    for item in items:
        inventory_left.transfer(item, inventory_right);



func _on_rtol_pressed() -> void:
    var items: Array = ctrl_inventory_right.get_selected_inventory_items();
    if items.empty():
        return;

    for item in items:
        inventory_right.transfer(item, inventory_left);
