@tool
@icon("res://addons/gloot/images/icon_ctrl_item_slot.svg")
class_name CtrlItemSlotEx
extends CtrlItemSlot

## A UI control similar to [CtrlItemSlot] but with extended options for
## customization.

## Style of the slot background.
@export var slot_style: StyleBox :
    set(new_slot_style):
        slot_style = new_slot_style
        _refresh()

## Style of the slot background when the mouse hovers over it.
@export var slot_highlighted_style: StyleBox :
    set(new_slot_highlighted_style):
        slot_highlighted_style = new_slot_highlighted_style
        _refresh()
var _background_panel: Panel


func _ready():
    super._ready()
    resized.connect(func():
        if is_instance_valid(_background_panel):
            _background_panel.size = size
    )


func _refresh() -> void:
    super._refresh()
    _update_background()


func _update_background() -> void:
    if !is_instance_valid(_background_panel):
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


func _on_mouse_entered():
    if slot_highlighted_style:
        _set_panel_style(_background_panel, slot_highlighted_style)
    super._on_mouse_entered()


func _on_mouse_exited():
    if slot_style:
        _set_panel_style(_background_panel, slot_style)
    else:
        _background_panel.hide()
    super._on_mouse_exited()
