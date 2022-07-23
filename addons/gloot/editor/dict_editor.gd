extends Control
tool

signal value_changed


onready var grid_container = $GridContainer
onready var lbl_name = $GridContainer/LblTitleName
onready var lbl_type = $GridContainer/LblTitleType
onready var lbl_value = $GridContainer/LblTitleValue

export(Dictionary) var dictionary: Dictionary setget _set_dictionary
export(Dictionary) var color_map: Dictionary setget _set_color_map
export(Color) var default_color: Color = Color.white setget _set_default_color


func _ready() -> void:
    refresh()


func _set_dictionary(new_dictionary: Dictionary) -> void:
    dictionary = new_dictionary
    refresh()


func _set_color_map(new_color_map: Dictionary) -> void:
    color_map = new_color_map
    refresh()


func _set_default_color(new_default_color: Color) -> void:
    default_color = new_default_color
    refresh()


func refresh() -> void:
    if !is_inside_tree():
        return
    _clear()
    lbl_name.add_color_override("font_color", default_color)
    lbl_type.add_color_override("font_color", default_color)
    lbl_value.add_color_override("font_color", default_color)
    _populate()


func _clear() -> void:
    for child in grid_container.get_children():
        if (child == lbl_name) || (child == lbl_type) || (child == lbl_value):
            continue
        child.queue_free()


func _populate() -> void:
    for key in dictionary.keys():
        var color: Color = default_color
        if color_map.has(key) && typeof(color_map[key]) == TYPE_COLOR:
            color = color_map[key]

        _add_key(key, color)


func _add_key(key: String, color: Color) -> void:
    if !(key is String):
        return

    var value = dictionary[key]
    _add_label(key, color)
    _add_label(GlootVerify.type_names[typeof(dictionary[key])], color)
    _add_line_edit(key)


func _add_label(key: String, color: Color) -> void:
    var label: Label = Label.new()
    label.text = key
    label.align = Label.ALIGN_CENTER
    label.add_color_override("font_color", color)
    grid_container.add_child(label)


func _add_line_edit(key: String) -> void:
    var line_edit: LineEdit = LineEdit.new()
    var value = dictionary[key]
    line_edit.text = var2str(value)
    line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
    line_edit.connect("text_entered", self, "_on_value_entered", [key, line_edit])
    grid_container.add_child(line_edit)


func _on_value_entered(text: String, key: String, line_edit: LineEdit) -> void:
    var new_value = str2var(text)
    if typeof(new_value) != typeof(dictionary[key]):
        line_edit.text = var2str(dictionary[key])
        return
    dictionary[key] = new_value
    emit_signal("value_changed", key, new_value)
    refresh()
