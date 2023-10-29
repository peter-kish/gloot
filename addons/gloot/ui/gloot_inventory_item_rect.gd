@tool
extends TextureRect

signal selected_status_changed

@export var selection_style: StyleBox :
    get:
        return selection_style
    set(new_selection_style):
        if new_selection_style == selection_style:
            return
        selection_style = new_selection_style
        _set_selection_style(selection_style)

var item: InventoryItem = null
var _label_stack_size: Label = null
var _panel_selection: Panel = null
var selected: bool = false :
    get:
        return selected
    set(new_selected):
        if selected == new_selected:
            return
        selected = new_selected
        if _panel_selection != null:
            _panel_selection.visible = selected
        selected_status_changed.emit()


func _ready() -> void:
    _panel_selection = Panel.new()
    _panel_selection.size = size
    _panel_selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _panel_selection.visible = selected
    add_child(_panel_selection)
    _set_selection_style(selection_style)
    item_rect_changed.connect(func():
        _panel_selection.size = size
    )

    _label_stack_size = Label.new()
    add_child(_label_stack_size)

    _update_stack_size_label()


func _set_selection_style(style: StyleBox) -> void:
    if _panel_selection == null:
        return
    _panel_selection.remove_theme_stylebox_override("panel")
    if style != null:
        _panel_selection.add_theme_stylebox_override("panel", style)


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

    var stacks_constraint = inventory.get_stacks_constraint()
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

    var stacks_constraint = inventory.get_stacks_constraint()
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

    var stacks_constraint = inventory.get_stacks_constraint()
    if stacks_constraint == null:
        return

    stacks_constraint.join_stacks_autosplit(item, data.item)

