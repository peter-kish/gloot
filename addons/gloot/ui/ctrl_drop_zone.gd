@tool
extends Control

signal dragable_dropped(control, position)

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

var _mouse_inside := false
static var _drop_event: Dictionary = {}


func _process(_delta) -> void:
    if _drop_event.is_empty():
        return
    
    if _drop_event.zone == null:
        CtrlDragable.release()
    else:
        if _drop_event.zone != self:
            return
        _drop_event.zone.dragable_dropped.emit(
            CtrlDragable.get_grabbed_dragable(),
            get_local_mouse_position() - CtrlDragable.get_grab_offset()
        )
        CtrlDragable.release_on(self)

    _drop_event = {}


func _input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton):
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.is_pressed() || mb_event.button_index != MOUSE_BUTTON_LEFT:
        return

    if CtrlDragable.get_grabbed_dragable() == null:
        return

    if _mouse_inside:
        _drop_event = {zone = self}
    elif _drop_event.is_empty():
        _drop_event = {zone = null}


func _ready() -> void:
    mouse_entered.connect(func(): _mouse_inside = true)
    mouse_exited.connect(func(): _mouse_inside = false)

