extends MarginContainer

signal value_changed

const MultifloatEditor = preload("res://addons/gloot/editor/multifloat_editor.gd")

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
    var control: Control = null

    match type:
        TYPE_COLOR:
            control = _create_color_picker()
        TYPE_BOOL:
            control = _create_checkbox()
        TYPE_VECTOR2:
            control = _create_v2_editor()
        TYPE_VECTOR3:
            control = _create_v3_editor()
        TYPE_RECT2:
            control = _create_r2_editor()
        _:
            control = _create_line_edit()

    add_child(control)


func _create_line_edit() -> LineEdit:
    var line_edit: LineEdit = LineEdit.new()
    line_edit.text = var2str(value)
    _expand_control(line_edit)
    line_edit.connect("text_entered", self, "_on_line_edit_value_entered", [line_edit])
    return line_edit


func _on_line_edit_value_entered(text: String, line_edit: LineEdit) -> void:
    var new_value = str2var(text)
    if typeof(new_value) != typeof(value):
        line_edit.text = var2str(value)
        return
    value = new_value
    emit_signal("value_changed")


func _create_color_picker() -> ColorPickerButton:
    var picker: ColorPickerButton = ColorPickerButton.new()
    picker.color = value
    _expand_control(picker)
    picker.connect("popup_closed", self, "_on_color_picked", [picker])
    return picker


func _on_color_picked(picker: ColorPickerButton) -> void:
    value = picker.color
    emit_signal("value_changed")


func _create_checkbox() -> CheckButton:
    var checkbox: CheckButton = CheckButton.new()
    checkbox.pressed = value
    _expand_control(checkbox)
    checkbox.connect("pressed", self, "_on_checkbox", [checkbox])
    return checkbox


func _on_checkbox(checkbox: CheckButton) -> void:
    value = checkbox.pressed
    emit_signal("value_changed")


func _create_v2_editor() -> Control:
    var values = [value.x, value.y]
    var titles = ["X", "Y"]
    var v2_editor = _create_multifloat_editor(2, values, titles, "_on_v2_value_changed")
    return v2_editor


func _on_v2_value_changed(_idx: int, v2_editor: Control) -> void:
    value.x = v2_editor.values[0]
    value.y = v2_editor.values[1]
    emit_signal("value_changed")


func _create_v3_editor() -> Control:
    var values = [value.x, value.y, value.z]
    var titles = ["X", "Y", "Z"]
    var v3_editor = _create_multifloat_editor(3, values, titles, "_on_v3_value_changed")
    return v3_editor


func _on_v3_value_changed(_idx: int, v3_editor: Control) -> void:
    value.x = v3_editor.values[0]
    value.y = v3_editor.values[1]
    value.z = v3_editor.values[2]
    emit_signal("value_changed")


func _create_r2_editor() -> Control:
    var values = [value.position.x, value.position.y, value.size.x, value.size.y]
    var titles = ["Position X", "Position Y", "Size X", "Size Y"]
    var r2_editor = _create_multifloat_editor(2, values, titles, "_on_r2_value_changed")
    return r2_editor


func _on_r2_value_changed(_idx: int, r2_editor: Control) -> void:
    value.position.x = r2_editor.values[0]
    value.position.y = r2_editor.values[1]
    value.size.x = r2_editor.values[2]
    value.size.y = r2_editor.values[3]
    emit_signal("value_changed")


func _create_multifloat_editor(
        columns: int,
        values: Array,
        titles: Array,
        value_changed_handler: String) -> Control:
    var multifloat_editor = MultifloatEditor.new()
    multifloat_editor.columns = columns
    multifloat_editor.values = values
    multifloat_editor.titles = titles
    _expand_control(multifloat_editor)
    multifloat_editor.connect("value_changed", self, value_changed_handler, [multifloat_editor])
    return multifloat_editor


func _expand_control(c: Control) -> void:
    c.size_flags_horizontal = SIZE_EXPAND_FILL
    c.anchor_right = 1.0
    c.anchor_bottom = 1.0