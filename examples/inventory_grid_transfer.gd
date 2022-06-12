extends Control

onready var ctrl_inventory_left: CtrlInventoryGrid = $VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/CtrlInventoryGridLeft;
onready var ctrl_inventory_right: CtrlInventoryGrid = $VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer2/CtrlInventoryGridRight;
onready var rect: TextureRect = $TextureRect;
onready var btn_sort_left: Button = $VBoxContainer/HBoxContainer/VBoxContainer/BtnSortLeft;
onready var btn_sort_right: Button = $VBoxContainer/HBoxContainer/VBoxContainer2/BtnSortRight;


func _ready() -> void:
    ctrl_inventory_left.connect("item_dropped", self, "_on_item_dropped", [ctrl_inventory_left]);
    ctrl_inventory_right.connect("item_dropped", self, "_on_item_dropped", [ctrl_inventory_right]);
    btn_sort_left.connect("pressed", self, "_on_btn_sort", [ctrl_inventory_left]);
    btn_sort_right.connect("pressed", self, "_on_btn_sort", [ctrl_inventory_right]);


func _on_item_dropped(item: InventoryItem, drop_pos: Vector2, ctrl_source_inventory: CtrlInventoryGrid) -> void:
    var ctrl_dest_inventory: CtrlInventoryGrid = null;
    if ctrl_source_inventory == ctrl_inventory_left:
        ctrl_dest_inventory = ctrl_inventory_right;
    elif ctrl_source_inventory == ctrl_inventory_right:
        ctrl_dest_inventory = ctrl_inventory_left;
    else:
        return;

    var field_coords: Vector2 = ctrl_dest_inventory._get_field_coords(drop_pos);
    ctrl_source_inventory.inventory.transfer_to(item, ctrl_dest_inventory.inventory, field_coords.x , field_coords.y);


func _on_btn_sort(ctrl_inventory: CtrlInventoryGrid) -> void:
    ctrl_inventory.inventory.sort();


func _process(_delta) -> void:
    var ctrl_inventory = null;
    if ctrl_inventory_left && ctrl_inventory_left.grabbed_ctrl_inventory_item:
        ctrl_inventory = ctrl_inventory_left;
    elif ctrl_inventory_right && ctrl_inventory_right.grabbed_ctrl_inventory_item:
        ctrl_inventory = ctrl_inventory_right;
    else:
        rect.visible = false;
        return;
        
    rect.visible = true;
    var ctrl_item = ctrl_inventory.grabbed_ctrl_inventory_item;
    var grabbed_ctrl_item_size = ctrl_inventory.inventory.get_item_size(ctrl_item.item);
    var item_size: Vector2 = Vector2(grabbed_ctrl_item_size.x * ctrl_inventory.field_dimensions.x, \
        grabbed_ctrl_item_size.y * ctrl_inventory.field_dimensions.y);
        
    rect.texture = ctrl_item.texture;
    rect.rect_size = item_size;
    rect.set_global_position(get_global_mouse_position() - ctrl_inventory.grab_offset);
