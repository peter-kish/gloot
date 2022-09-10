extends HBoxContainer

signal value_changed

var values: Array = [] setget _set_values
var titles: Array = [] setget _set_titles


func _set_values(new_values: Array) -> void:
    assert(!is_inside_tree(), "Can't set values once the node is inside a tree")
    values = new_values


func _set_titles(new_titles: Array) -> void:
    assert(!is_inside_tree(), "Can't set titles once the node is inside a tree")
    titles = new_titles


func _ready() -> void:
    for i in values.size():
        if i < titles.size():

            var label: Label = Label.new()
            label.text = "%s:" % titles[i]
            add_child(label)

        var line_edit: LineEdit = LineEdit.new()
        line_edit.text = var2str(values[i])
        line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
        line_edit.connect("text_entered", self, "_on_line_edit_value_entered", [line_edit, i])
        add_child(line_edit)


func _on_line_edit_value_entered(text: String, line_edit: LineEdit, idx: int) -> void:
    var value = str2var(text)
    if typeof(value) != TYPE_REAL:
        line_edit.text = var2str(values[idx])
        return
    values[idx] = value
    emit_signal("value_changed", idx)