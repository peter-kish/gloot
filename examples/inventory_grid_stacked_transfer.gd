extends Control

const info_offset: Vector2 = Vector2(20, 0)

@onready var ctrl_inventory_left := $"%CtrlInventoryGridLeft"
@onready var ctrl_inventory_right := $"%CtrlInventoryGridRight"
@onready var btn_sort_left: Button = $"%BtnSortLeft"
@onready var btn_sort_right: Button = $"%BtnSortRight"
@onready var btn_split_left: Button = $"%BtnSplitLeft"
@onready var btn_split_right: Button = $"%BtnSplitRight"
@onready var ctrl_slot: CtrlItemSlot = $"%CtrlItemSlot"
@onready var btn_unequip: Button = $"%BtnUnequip"
@onready var lbl_info: Label = $"%LblInfo"


func _ready() -> void:
    ctrl_inventory_left.item_mouse_entered.connect(_on_item_mouse_entered)
    ctrl_inventory_left.item_mouse_exited.connect(_on_item_mouse_exited)
    ctrl_inventory_right.item_mouse_entered.connect(_on_item_mouse_entered)
    ctrl_inventory_right.item_mouse_exited.connect(_on_item_mouse_exited)
    btn_sort_left.pressed.connect(_on_btn_sort.bind(ctrl_inventory_left))
    btn_sort_right.pressed.connect(_on_btn_sort.bind(ctrl_inventory_right))
    btn_split_left.pressed.connect(_on_btn_split.bind(ctrl_inventory_left))
    btn_split_right.pressed.connect(_on_btn_split.bind(ctrl_inventory_right))
    btn_unequip.pressed.connect(_on_btn_unequip)


func _on_item_mouse_entered(item: InventoryItem) -> void:
    lbl_info.show()
    lbl_info.text = item.prototype_id


func _on_item_mouse_exited(_item: InventoryItem) -> void:
    lbl_info.hide()


func _input(event: InputEvent) -> void:
    if !(event is InputEventMouseMotion):
        return

    lbl_info.set_global_position(get_global_mouse_position() + info_offset)


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
    return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
    ctrl_inventory_left.inventory.remove_item(data.item)
    ctrl_inventory_right.inventory.remove_item(data.item)
    # Replace the following line with custom logic for handling the item drop:
    data.item.queue_free()


func _on_btn_sort(ctrl_inventory) -> void:
    if !ctrl_inventory.inventory.sort():
        print("Warning: InventoryGrid.sort() returned false!")


func _on_btn_split(ctrl_inventory) -> void:
    var inventory_stacked := (ctrl_inventory.inventory as InventoryGridStacked)
    if inventory_stacked == null:
        print("Warning: inventory is not InventoryGridStacked!")
        return

    var selected_items = ctrl_inventory.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        var stack_size := InventoryGridStacked.get_item_stack_size(selected_item)
        if stack_size < 2:
            return

        # All this floor/float jazz just to do integer division without warnings
        var new_stack_size: int = floor(float(stack_size) / 2)
        inventory_stacked.split(selected_item, new_stack_size)


func _on_btn_unequip() -> void:
    ctrl_slot.item_slot.clear()
