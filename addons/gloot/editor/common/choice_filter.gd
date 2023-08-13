@tool
extends Control

signal choice_picked(value_index)
signal choice_selected(value_index)


@onready var lbl_filter: Label = $HBoxContainer/Label
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var item_list: ItemList = $ItemList
@onready var btn_pick: Button = $Button
@export var pick_button_visible: bool = true :
    get:
        return pick_button_visible
    set(new_pick_button_visible):
        pick_button_visible = new_pick_button_visible
        if btn_pick:
            btn_pick.visible = pick_button_visible
@export var pick_text: String :
    get:
        return pick_text
    set(new_pick_text):
        pick_text = new_pick_text
        if btn_pick:
            btn_pick.text = pick_text
@export var pick_icon: Texture2D :
    get:
        return pick_icon
    set(new_pick_icon):
        pick_icon = new_pick_icon
        if btn_pick:
            btn_pick.icon = pick_icon
@export var filter_text: String = "Filter:" :
    get:
        return filter_text
    set(new_filter_text):
        filter_text = new_filter_text
        if lbl_filter:
            lbl_filter.text = filter_text
@export var filter_icon: Texture2D :
    get:
        return filter_icon
    set(new_filter_icon):
        filter_icon = new_filter_icon
        if line_edit:
            line_edit.right_icon = filter_icon
@export var values: Array[String]


func refresh() -> void:
    _clear()
    _populate()


func _clear() -> void:
    if item_list:
        item_list.clear()


func _populate() -> void:
    if line_edit == null || item_list == null:
        return

    if values == null || values.size() == 0:
        return

    for value_index in range(values.size()):
        var value = values[value_index]
        assert(value is String, "values must be an array of strings!")

        if !line_edit.text.is_empty() && !(line_edit.text.to_lower() in value.to_lower()):
            continue

        item_list.add_item(value)
        item_list.set_item_metadata(item_list.get_item_count() - 1, value_index)


func _ready() -> void:
    btn_pick.pressed.connect(Callable(self, "_on_btn_pick"))
    line_edit.text_changed.connect(Callable(self, "_on_filter_text_changed"))
    item_list.item_activated.connect(Callable(self, "_on_item_activated"))
    item_list.item_selected.connect(Callable(self, "_on_item_selected"))
    refresh()
    if btn_pick:
        btn_pick.text = pick_text
        btn_pick.icon = pick_icon
        btn_pick.visible = pick_button_visible
    if lbl_filter:
        lbl_filter.text = filter_text
    if line_edit:
        line_edit.right_icon = filter_icon


func _on_btn_pick() -> void:
    var selected_items: PackedInt32Array = item_list.get_selected_items()
    if selected_items.size() == 0:
        return

    var selected_item = selected_items[0]
    var selected_value_index = item_list.get_item_metadata(selected_item)
    choice_picked.emit(selected_value_index)


func _on_filter_text_changed(_new_text: String) -> void:
    refresh()


func _on_item_activated(index: int) -> void:
    var selected_value_index = item_list.get_item_metadata(index)
    choice_picked.emit(selected_value_index)


func _on_item_selected(index: int) -> void:
    var selected_value_index = item_list.get_item_metadata(index)
    choice_selected.emit(selected_value_index)


func get_selected_item() -> int:
    var selected := item_list.get_selected_items()
    if selected.size() > 0:
        return item_list.get_item_metadata(selected[0])
    return -1


func get_selected_text() -> String:
    var selected := get_selected_item()
    if selected >= 0:
        return values[selected]
        
    return ""
    
    
func set_values(new_values: Array) -> void:
    values.clear()
    for new_value in new_values:
        if typeof(new_value) == TYPE_STRING:
            values.push_back(new_value)

    refresh()
