@tool
extends Panel

signal item_dropped(item)

@export var style: StyleBox :
    set(new_style):
        style = new_style
        if !selected:
            _set_active_style(style)

@export var hover_style: StyleBox :
    set(new_hover_style):
        hover_style = new_hover_style

@export var selected_style: StyleBox :
    set(new_selected_style):
        selected_style = new_selected_style
        if selected:
            _set_active_style(selected_style)

@export var selected: bool :
    set(new_selected):
        selected = new_selected
        if selected:
            _set_active_style(selected_style)
        else:
            _set_active_style(style)


func _set_active_style(style: StyleBox) -> void:
    remove_theme_stylebox_override("panel")
    if style != null:
        add_theme_stylebox_override("panel", style)


func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
    if !selected && (hover_style != null):
        _set_active_style(hover_style)


func _on_mouse_exited() -> void:
    if !selected:
        _set_active_style(style)


func _can_drop_data(at_position, data) -> bool:
    # TODO: Implement
    return true


func _drop_data(at_position, data):
    item_dropped.emit(data.item)
