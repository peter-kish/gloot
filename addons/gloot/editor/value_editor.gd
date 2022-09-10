extends Control

signal value_changed

var value setget _set_value


func _set_value(new_value) -> void:
    value = new_value
    _refresh()


func _ready():
    _refresh()


func _refresh():
    _clear()
    _add_control()


func _clear() -> void:
    for c in get_children():
        c.queue_free()


func _add_control() -> void:
    var type = typeof(value)

    match type:
        TYPE_COLOR:
            _create_color_picker()
        TYPE_BOOL:
            _create_checkbox()
        _:
            _add_line_edit()


func _add_line_edit() -> void:
    var line_edit: LineEdit = LineEdit.new()
    line_edit.text = var2str(value)
    line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
    line_edit.anchor_right = 1.0
    line_edit.anchor_bottom = 1.0
    line_edit.connect("text_entered", self, "_on_line_edit_value_entered", [line_edit])
    add_child(line_edit)


func _on_line_edit_value_entered(text: String, line_edit: LineEdit) -> void:
    var new_value = str2var(text)
    if typeof(new_value) != typeof(value):
        line_edit.text = var2str(value)
        return
    value = new_value
    emit_signal("value_changed", value)


func _create_color_picker() -> void:
    var picker: ColorPickerButton = ColorPickerButton.new()
    picker.color = value
    picker.size_flags_horizontal = SIZE_EXPAND_FILL
    picker.anchor_right = 1.0
    picker.anchor_bottom = 1.0
    picker.connect("popup_closed", self, "_on_color_picked", [picker])
    add_child(picker)


func _on_color_picked(picker: ColorPickerButton) -> void:
    value = picker.color
    emit_signal("value_changed", value)


func _create_checkbox() -> void:
    var checkbox: CheckButton = CheckButton.new()
    checkbox.pressed = value
    checkbox.size_flags_horizontal = SIZE_EXPAND_FILL
    checkbox.anchor_right = 1.0
    checkbox.anchor_bottom = 1.0
    checkbox.connect("pressed", self, "_on_checkbox", [checkbox])
    add_child(checkbox)


func _on_checkbox(checkbox: CheckButton) -> void:
    value = checkbox.pressed
    emit_signal("value_changed", value)
