extends Control

const info_offset: Vector2 = Vector2(20, 0)


func _ready() -> void:
    %CtrlInventoryGridLeft.item_mouse_entered.connect(_on_item_mouse_entered)
    %CtrlInventoryGridLeft.item_mouse_exited.connect(_on_item_mouse_exited)
    %CtrlInventoryGridRight.item_mouse_entered.connect(_on_item_mouse_entered)
    %CtrlInventoryGridRight.item_mouse_exited.connect(_on_item_mouse_exited)
    %BtnSortLeft.pressed.connect(_on_btn_sort.bind(%CtrlInventoryGridLeft))
    %BtnSortRight.pressed.connect(_on_btn_sort.bind(%CtrlInventoryGridRight))
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


func _on_btn_unequip() -> void:
    %InventoryRight.add_item(%ItemSlot.get_item())


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    return data is InventoryItem


func _drop_data(_at_position: Vector2, data: Variant) -> void:
    %CtrlInventoryGridLeft.inventory.remove_item(data)
    %CtrlInventoryGridRight.inventory.remove_item(data)
    # Add custom logic for handling the item drop here
