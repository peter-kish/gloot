extends GridContainer

signal value_changed(value_index)


var values: Array = [] :
    get:
        return values
    set(new_values):
        assert(!is_inside_tree(), "Can't set values once the node is inside a tree")
        values = new_values
var titles: Array = [] :
    get:
        return titles
    set(new_titles):
        assert(!is_inside_tree(), "Can't set titles once the node is inside a tree")
        titles = new_titles
var enabled: bool = true
var type: int = TYPE_FLOAT


func _ready() -> void:
    for i in values.size():
        var hbox: HBoxContainer = HBoxContainer.new()
        hbox.size_flags_horizontal = SIZE_EXPAND_FILL

        if i < titles.size():
            var label: Label = Label.new()
            label.text = "%s:" % titles[i]
            hbox.add_child(label)
        else:
            var dummy: Control = Control.new()
            hbox.add_child(dummy)

        var line_edit: LineEdit = LineEdit.new()
        line_edit.text = var_to_str(values[i])
        line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
        line_edit.text_submitted.connect(Callable(self, "_on_line_edit_value_entered").bind(line_edit, i))
        line_edit.focus_exited.connect(Callable(self, "_on_line_edit_focus_exited").bind(line_edit, i))
        line_edit.editable = enabled
        hbox.add_child(line_edit)

        add_child(hbox)


func _on_line_edit_value_entered(_text: String, line_edit: LineEdit, idx: int) -> void:
    _on_line_edit_focus_exited(line_edit, idx)


func _on_line_edit_focus_exited(line_edit: LineEdit, idx: int) -> void:
    var value = str_to_var(line_edit.text)
    if typeof(value) != type:
        line_edit.text = var_to_str(values[idx])
        return
    values[idx] = value
    value_changed.emit(idx)
