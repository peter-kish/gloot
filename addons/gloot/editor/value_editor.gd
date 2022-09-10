extends MarginContainer

signal value_changed

const MultifloadEditor = preload("res://addons/gloot/editor/multifloat_editor.gd")

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
        TYPE_VECTOR2:
            _create_v2_editor()
        TYPE_VECTOR3:
            _create_v3_editor()
        TYPE_RECT2:
            _create_r2_editor()
        _:
            _create_line_edit()


func _create_line_edit() -> LineEdit:
    var line_edit: LineEdit = LineEdit.new()
    line_edit.text = var2str(value)
    _expand_control(line_edit)
    line_edit.connect("text_entered", self, "_on_line_edit_value_entered", [line_edit])
    add_child(line_edit)
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
    add_child(picker)
    return picker


func _on_color_picked(picker: ColorPickerButton) -> void:
    value = picker.color
    emit_signal("value_changed")


func _create_checkbox() -> CheckButton:
    var checkbox: CheckButton = CheckButton.new()
    checkbox.pressed = value
    _expand_control(checkbox)
    checkbox.connect("pressed", self, "_on_checkbox", [checkbox])
    add_child(checkbox)
    return checkbox


func _on_checkbox(checkbox: CheckButton) -> void:
    value = checkbox.pressed
    emit_signal("value_changed")


func _create_v2_editor() -> Control:
    var v2_editor = MultifloadEditor.new()
    v2_editor.columns = 2
    v2_editor.values = [value.x, value.y]
    v2_editor.titles = ["X", "Y"]
    _expand_control(v2_editor)
    v2_editor.connect("value_changed", self, "_on_v2_value_changed", [v2_editor])
    add_child(v2_editor)
    return v2_editor


func _on_v2_value_changed(_idx: int, v2_editor: Control) -> void:
    value.x = v2_editor.values[0]
    value.y = v2_editor.values[1]
    emit_signal("value_changed")


func _create_v3_editor() -> Control:
    var v3_editor = MultifloadEditor.new()
    v3_editor.columns = 3
    v3_editor.values = [value.x, value.y, value.z]
    v3_editor.titles = ["X", "Y", "Z"]
    _expand_control(v3_editor)
    v3_editor.connect("value_changed", self, "_on_v3_value_changed", [v3_editor])
    add_child(v3_editor)
    return v3_editor


func _on_v3_value_changed(_idx: int, v3_editor: Control) -> void:
    value.x = v3_editor.values[0]
    value.y = v3_editor.values[1]
    value.z = v3_editor.values[2]
    emit_signal("value_changed")


func _create_r2_editor() -> Control:
    var r2_editor = MultifloadEditor.new()
    r2_editor.columns = 2
    r2_editor.values = [value.position.x, value.position.y, value.size.x, value.size.y]
    r2_editor.titles = ["Position X", "Position Y", "Size X", "Size Y"]
    _expand_control(r2_editor)
    r2_editor.connect("value_changed", self, "_on_r2_value_changed", [r2_editor])
    add_child(r2_editor)
    return r2_editor


func _on_r2_value_changed(_idx: int, r2_editor: Control) -> void:
    value.position.x = r2_editor.values[0]
    value.position.y = r2_editor.values[0]
    value.size.x = r2_editor.values[0]
    value.size.y = r2_editor.values[0]
    emit_signal("value_changed")


func _expand_control(c: Control) -> void:
    c.size_flags_horizontal = SIZE_EXPAND_FILL
    c.anchor_right = 1.0
    c.anchor_bottom = 1.0