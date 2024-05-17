extends Control

const info_offset: Vector2 = Vector2(20, 0)

const StackManager = preload("res://addons/gloot/core/stack_manager.gd")


func _ready() -> void:
    %CtrlInventoryGridLeft.item_mouse_entered.connect(_on_item_mouse_entered)
    %CtrlInventoryGridLeft.item_mouse_exited.connect(_on_item_mouse_exited)
    %CtrlInventoryGridRight.item_mouse_entered.connect(_on_item_mouse_entered)
    %CtrlInventoryGridRight.item_mouse_exited.connect(_on_item_mouse_exited)
    %BtnSortLeft.pressed.connect(_on_btn_sort.bind(%CtrlInventoryGridLeft))
    %BtnSortRight.pressed.connect(_on_btn_sort.bind(%CtrlInventoryGridRight))
    %BtnSplitLeft.pressed.connect(_on_btn_split.bind(%CtrlInventoryGridLeft))
    %BtnSplitRight.pressed.connect(_on_btn_split.bind(%CtrlInventoryGridRight))
    %BtnUnequip.pressed.connect(_on_btn_unequip)


func _on_item_mouse_entered(item: InventoryItem) -> void:
    %LblInfo.show()
    %LblInfo.text = item.get_title()


func _on_item_mouse_exited(_item: InventoryItem) -> void:
    %LblInfo.hide()


func _input(event: InputEvent) -> void:
    if !(event is InputEventMouseMotion):
        return

    %LblInfo.set_global_position(get_global_mouse_position() + info_offset)


func _on_btn_sort(ctrl_inventory) -> void:
    if !ctrl_inventory.inventory.get_constraint(GridConstraint).sort():
        print("Warning: GridConstraint.sort() returned false!")


func _on_btn_split(ctrl_inventory) -> void:
    var selected_items = ctrl_inventory.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        var stack_size := StackManager.get_item_stack_size(selected_item)
        if stack_size.lt(ItemCount.new(2)):
            return

        # All this floor/float jazz just to do integer division without warnings
        var new_stack_size: int = floor(float(stack_size.count) / 2)
        StackManager.inv_split_stack(ctrl_inventory.inventory, selected_item, ItemCount.new(new_stack_size))


func _on_btn_unequip() -> void:
    %InventoryRight.add_item(%CtrlItemSlot.item_slot.get_item())

