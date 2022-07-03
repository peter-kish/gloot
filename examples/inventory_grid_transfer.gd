extends Control

onready var ctrl_inventory_left: CtrlInventoryGrid = $VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/CtrlInventoryGridLeft
onready var ctrl_inventory_right: CtrlInventoryGrid = $VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer2/CtrlInventoryGridRight
onready var btn_sort_left: Button = $VBoxContainer/HBoxContainer/VBoxContainer/BtnSortLeft
onready var btn_sort_right: Button = $VBoxContainer/HBoxContainer/VBoxContainer2/BtnSortRight
onready var ctrl_slot: CtrlItemSlot = $VBoxContainer/HBoxContainer/VBoxContainer3/PanelContainer/CtrlItemSlot
onready var btn_unequip: Button = $VBoxContainer/HBoxContainer/VBoxContainer3/BtnUnequip


func _ready() -> void:
    ctrl_inventory_left.connect("item_dropped", self, "_on_item_dropped", [ctrl_inventory_left])
    ctrl_inventory_right.connect("item_dropped", self, "_on_item_dropped", [ctrl_inventory_right])
    btn_sort_left.connect("pressed", self, "_on_btn_sort", [ctrl_inventory_left])
    btn_sort_right.connect("pressed", self, "_on_btn_sort", [ctrl_inventory_right])
    btn_unequip.connect("pressed", self, "_on_btn_unequip")


func _on_item_dropped(item: InventoryItem, drop_pos: Vector2, ctrl_source_inventory: CtrlInventoryGrid) -> void:
    var ctrl_dest_inventory: CtrlInventoryGrid = null
    if ctrl_source_inventory == ctrl_inventory_left:
        ctrl_dest_inventory = ctrl_inventory_right
    elif ctrl_source_inventory == ctrl_inventory_right:
        ctrl_dest_inventory = ctrl_inventory_left
    else:
        return

    var field_coords: Vector2 = ctrl_dest_inventory.get_field_coords(drop_pos)
    if !ctrl_source_inventory.inventory.transfer_to( \
            item, \
            ctrl_dest_inventory.inventory, \
            field_coords):
        var slot_rect = ctrl_slot.get_global_rect()
        if slot_rect.has_point(drop_pos) && ctrl_slot.item_slot.can_hold_item(item):
            ctrl_slot.item_slot.item = item


func _on_btn_sort(ctrl_inventory: CtrlInventoryGrid) -> void:
    if !ctrl_inventory.inventory.sort():
        print("Warning: InventoryGrid.sort() returned false!")


func _on_btn_unequip() -> void:
    ctrl_slot.item_slot.item = null

