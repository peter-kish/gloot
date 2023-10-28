@tool
extends TextureRect

signal selected_status_changed

var item: InventoryItem = null
var _label_stack_size: Label = null
var selected: bool :
    get:
        return selected
    set(new_selected):
        if selected == new_selected:
            return
        selected = new_selected
        selected_status_changed.emit()


func _ready() -> void:
    _label_stack_size = Label.new()
    add_child(_label_stack_size)
    _update_stack_size_label()


func _gui_input(event):
    if !(event is InputEventMouseButton):
        return
    if !event.pressed:
        return
    if event.button_index != MOUSE_BUTTON_LEFT:
        return

    selected = true


func _update_stack_size_label() -> void:
    if _label_stack_size == null:
        return
    _label_stack_size.text = ""

    if item == null:
        return

    var inventory := item.get_inventory()
    if inventory == null:
        return

    var stacks_constraint = inventory._constraint_manager.get_stacks_constraint()
    if stacks_constraint == null:
        return

    var stack_size: int = stacks_constraint.get_item_stack_size(item)
    if stack_size <= 1:
        return
    _label_stack_size.text = str(stack_size)


func _get_drag_data(at_position: Vector2):
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_drag_preview(_get_drag_preview())
    return self


func _get_drag_preview() -> Control:
    var preview = TextureRect.new()
    preview.texture = texture
    preview.size = size
    return preview


func _notification(what) -> void:
    if what == NOTIFICATION_DRAG_END:
        _on_drag_end()
    elif what == NOTIFICATION_DRAG_BEGIN:
        var drag_data = get_viewport().gui_get_drag_data()
        if drag_data == null:
            return
        if drag_data.item == item:
            _on_drag_start()


func _on_drag_start() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    modulate = Color(1.0, 1.0, 1.0, 0.5)
    selected = true


func _on_drag_end() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    modulate = Color.WHITE


func _can_drop_data(at_position, data) -> bool:
    if item == null:
        return false

    var inventory = item.get_inventory()
    if inventory == null:
        return false

    var stacks_constraint = inventory._constraint_manager.get_stacks_constraint()
    if stacks_constraint == null:
        return false

    if !stacks_constraint.items_mergable(item, data.item):
        return false

    return true


func _drop_data(at_position, data):
    if item == null:
        return

    var inventory = item.get_inventory()
    if inventory == null:
        return

    var stacks_constraint = inventory._constraint_manager.get_stacks_constraint()
    if stacks_constraint == null:
        return

    stacks_constraint.join_stacks_autosplit(item, data.item)

