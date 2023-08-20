@tool
class_name CtrlItemSlotEx
extends CtrlItemSlot

@export var slot_style: StyleBox :
    get:
        return slot_style
    set(new_slot_style):
        slot_style = new_slot_style
        _refresh()
@export var slot_highlighted_style: StyleBox :
    get:
        return slot_highlighted_style
    set(new_slot_highlighted_style):
        slot_highlighted_style = new_slot_highlighted_style
        _refresh()
var _background_panel: Panel


func _refresh() -> void:
    super._refresh()
    _update_background()


func _update_background() -> void:
    if !_background_panel:
        _background_panel = Panel.new()
        add_child(_background_panel)
        move_child(_background_panel, 0)
        
    _background_panel.size = size
    _background_panel.show()
    if slot_style:
        _set_panel_style(_background_panel, slot_style)
    else:
        _background_panel.hide()


func _set_panel_style(panel: Panel, style: StyleBox) -> void:
    panel.remove_theme_stylebox_override("panel")
    if style != null:
        panel.add_theme_stylebox_override("panel", style)


func _input(event) -> void:
    if event is InputEventMouseMotion:
        if get_global_rect().has_point(get_global_mouse_position()) && slot_highlighted_style:
            _set_panel_style(_background_panel, slot_highlighted_style)
            return
        
        if slot_style:
            _set_panel_style(_background_panel, slot_style)
        else:
            _background_panel.hide()
