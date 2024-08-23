extends MarginContainer

signal value_changed

const _MultivalueEditor = preload("res://addons/gloot/editor/common/multivalue_editor.gd")
const _Utils = preload("res://addons/gloot/core/utils.gd")

var value:
    set(new_value):
        value = new_value
        call_deferred("_refresh")
var enabled: bool = true


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
        TYPE_VECTOR2I:
            control = _create_v2i_editor()
        TYPE_VECTOR3:
            control = _create_v3_editor()
        TYPE_VECTOR3I:
            control = _create_v3i_editor()
        TYPE_RECT2:
            control = _create_r2_editor()
        TYPE_RECT2I:
            control = _create_r2i_editor()
        TYPE_PLANE:
            control = _create_plane_editor()
        TYPE_QUATERNION:
            control = _create_quat_editor()
        TYPE_AABB:
            control = _create_aabb_editor()
        _:
            control = _create_line_edit()

    add_child(control)


func _create_line_edit() -> LineEdit:
    var line_edit: LineEdit = LineEdit.new()
    line_edit.text = var_to_str(value)
    line_edit.editable = enabled
    _expand_control(line_edit)
    line_edit.text_submitted.connect(_on_line_edit_value_entered.bind(line_edit))
    line_edit.focus_exited.connect(_on_line_edit_focus_exited.bind(line_edit))
    return line_edit


func _on_line_edit_value_entered(_text: String, line_edit: LineEdit) -> void:
    _on_line_edit_focus_exited(line_edit)


func _on_line_edit_focus_exited(line_edit: LineEdit) -> void:
    var new_value = _Utils.str_to_var(line_edit.text)
    if typeof(new_value) != typeof(value):
        line_edit.text = var_to_str(value)
        return
    if new_value == value:
        return
    value = new_value
    value_changed.emit()


func _create_color_picker() -> ColorPickerButton:
    var picker: ColorPickerButton = ColorPickerButton.new()
    picker.color = value
    picker.disabled = !enabled
    _expand_control(picker)
    picker.popup_closed.connect(_on_color_picked.bind(picker))
    return picker


func _on_color_picked(picker: ColorPickerButton) -> void:
    if picker.color == value:
        return
    value = picker.color
    value_changed.emit()


func _create_checkbox() -> CheckButton:
    var checkbox: CheckButton = CheckButton.new()
    checkbox.button_pressed = value
    checkbox.disabled = !enabled
    _expand_control(checkbox)
    checkbox.pressed.connect(_on_checkbox.bind(checkbox))
    return checkbox


func _on_checkbox(checkbox: CheckButton) -> void:
    if checkbox.button_pressed == value:
        return
    value = checkbox.button_pressed
    value_changed.emit()


func _create_v2_editor() -> Control:
    var values := [value.x, value.y]
    var titles := ["X", "Y"]
    var value_converter := func(values: Array):
        return Vector2(values[0], values[1])
    var v2_editor = _create_multifloat_editor(2, enabled, values, titles, value_converter)
    return v2_editor


func _create_v2i_editor() -> Control:
    var values := [value.x, value.y]
    var titles := ["X", "Y"]
    var value_converter := func(values: Array):
        return Vector2i(values[0], values[1])
    var v2_editor = _create_multiint_editor(2, enabled, values, titles, value_converter)
    return v2_editor


func _create_v3_editor() -> Control:
    var values := [value.x, value.y, value.z]
    var titles := ["X", "Y", "Z"]
    var value_converter := func(values: Array):
        return Vector3(values[0], values[1], values[2])
    var v3_editor = _create_multifloat_editor(3, enabled, values, titles, value_converter)
    return v3_editor


func _create_v3i_editor() -> Control:
    var values := [value.x, value.y, value.z]
    var titles := ["X", "Y", "Z"]
    var value_converter := func(values: Array):
        return Vector3i(values[0], values[1], values[2])
    var v3_editor = _create_multiint_editor(3, enabled, values, titles, value_converter)
    return v3_editor


func _create_r2_editor() -> Control:
    var values := [value.position.x, value.position.y, value.size.x, value.size.y]
    var titles := ["Position X", "Position Y", "Size X", "Size Y"]
    var value_converter := func(values: Array):
        return Rect2(
            values[0],
            values[1],
            values[2],
            values[3])
    var r2_editor = _create_multifloat_editor(2, enabled, values, titles, value_converter)
    return r2_editor


func _create_r2i_editor() -> Control:
    var values := [value.position.x, value.position.y, value.size.x, value.size.y]
    var titles := ["Position X", "Position Y", "Size X", "Size Y"]
    var value_converter := func(values: Array):
        return Rect2i(
            values[0],
            values[1],
            values[2],
            values[3])
    var r2_editor = _create_multiint_editor(2, enabled, values, titles, value_converter)
    return r2_editor


func _create_plane_editor() -> Control:
    var values := [value.x, value.y, value.z, value.d]
    var titles := ["A", "B", "C", "D"]
    var value_converter := func(values: Array):
        return Plane(
            values[0],
            values[1],
            values[2],
            values[3])
    var editor = _create_multifloat_editor(2, enabled, values, titles, value_converter)
    return editor


func _create_quat_editor() -> Control:
    var values := [value.x, value.y, value.z, value.w]
    var titles := ["X", "Y", "Z", "W"]
    var value_converter := func(values: Array):
        return Quaternion(
            values[0],
            values[1],
            values[2],
            values[3])
    var editor = _create_multifloat_editor(2, enabled, values, titles, value_converter)
    return editor


func _create_aabb_editor() -> Control:
    var values := [value.position.x, value.position.y, value.position.z, \
        value.size.x, value.size.y, value.size.z]
    var titles := ["Position X", "Position Y", "Position Z", "Size X", "Size Y", "Size Z"]
    var value_converter := func(values: Array):
        var result: AABB
        result.position.x = values[0]
        result.position.y = values[1]
        result.position.z = values[2]
        result.size.x = values[3]
        result.size.y = values[4]
        result.size.z = values[5]
        return result
    var editor = _create_multifloat_editor(3, enabled, values, titles, value_converter)
    return editor


func _create_multifloat_editor(
        columns: int,
        enabled: bool,
        values: Array,
        titles: Array,
        value_converter: Callable) -> Control:
    return _create_multivalue_editor(columns, enabled, TYPE_FLOAT, values, titles, value_converter)


func _create_multiint_editor(
        columns: int,
        enabled: bool,
        values: Array,
        titles: Array,
        value_converter: Callable) -> Control:
    return _create_multivalue_editor(columns, enabled, TYPE_INT, values, titles, value_converter)

    
func _create_multivalue_editor(
        columns: int,
        enabled: bool,
        type: int,
        values: Array,
        titles: Array,
        value_converter: Callable) -> Control:
    var multivalue_editor = _MultivalueEditor.new()
    multivalue_editor.columns = columns
    multivalue_editor.enabled = enabled
    multivalue_editor.type = type
    multivalue_editor.values = values
    multivalue_editor.titles = titles
    _expand_control(multivalue_editor)
    multivalue_editor.value_changed.connect(func(_idx: int):
        var new_value = value_converter.call(multivalue_editor.values)
        if new_value == value:
            return
        value = new_value
        value_changed.emit()
    )
    return multivalue_editor


func _expand_control(c: Control) -> void:
    c.size_flags_horizontal = SIZE_EXPAND_FILL
    c.anchor_right = 1.0
    c.anchor_bottom = 1.0
