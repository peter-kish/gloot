class_name CtrlItemSlotEx
extends CtrlItemSlot
tool

export(StyleBox) var field_style: StyleBox setget _set_field_style
export(StyleBox) var field_highlighted_style: StyleBox setget _set_field_highlighted_style
var _background_panel: Panel


func _set_field_style(new_field_style: StyleBox) -> void:
    field_style = new_field_style
    _refresh()


func _set_field_highlighted_style(new_field_highlighted_style: StyleBox) -> void:
    field_highlighted_style = new_field_highlighted_style
    _refresh()


func _refresh() -> void:
    ._refresh()
    _update_background()


func _update_background() -> void:
    if !_background_panel:
        _background_panel = Panel.new()
        _background_panel.rect_size = rect_size
        add_child(_background_panel)
        move_child(_background_panel, 0)
    _set_panel_style(_background_panel, field_style)


func _set_panel_style(panel: Panel, style: StyleBox) -> void:
    panel.remove_stylebox_override("panel")
    panel.add_stylebox_override("panel", style)


func _input(event) -> void:
    if event is InputEventMouseMotion:
        if get_global_rect().has_point(get_global_mouse_position()) && field_highlighted_style:
            _set_panel_style(_background_panel, field_highlighted_style)
            return
        
        _set_panel_style(_background_panel, field_style)
