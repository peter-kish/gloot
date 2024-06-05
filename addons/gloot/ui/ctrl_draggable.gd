@tool
extends Control

const CtrlDraggable = preload("res://addons/gloot/ui/ctrl_draggable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

# Somewhat hacky way to do static signals:
# https://stackoverflow.com/questions/77026156/how-to-write-a-static-event-emitter-in-gdscript/77026952#77026952

static var draggable_grabbed: Signal = (func():
    if (CtrlDraggable as Object).has_user_signal("draggable_grabbed"):
        return (CtrlDraggable as Object).draggable_grabbed
    (CtrlDraggable as Object).add_user_signal("draggable_grabbed")
    return Signal(CtrlDraggable, "draggable_grabbed")
).call()

static var draggable_dropped: Signal = (func():
    if (CtrlDraggable as Object).has_user_signal("draggable_dropped"):
        return (CtrlDraggable as Object).draggable_dropped
    (CtrlDraggable as Object).add_user_signal("draggable_dropped")
    return Signal(CtrlDraggable, "draggable_dropped")
).call()

signal grabbed(position)
signal dropped(zone, position)

static var _grabbed_draggable: CtrlDraggable = null
static var _grab_offset: Vector2

var _enabled: bool = true


static func get_grabbed_draggable() -> CtrlDraggable:
    if !is_instance_valid(_grabbed_draggable):
        return null
    return _grabbed_draggable


static func get_grab_offset() -> Vector2:
    return _grab_offset


static func get_grab_offset_local_to(control: Control) -> Vector2:
    return CtrlDraggable.get_grab_offset() / control.get_global_transform().get_scale()


func _get_drag_data(at_position: Vector2):
    if !_enabled:
        return null

    _grabbed_draggable = self
    _grab_offset = at_position * get_global_transform().get_scale()
    draggable_grabbed.emit(_grabbed_draggable, _grab_offset)
    grabbed.emit(_grab_offset)

    var preview = Control.new()
    var sub_preview = create_preview()
    sub_preview.position = -get_grab_offset()
    preview.add_child(sub_preview)
    set_drag_preview(preview)
    return self


func create_preview() -> Control:
    return null


func activate() -> void:
    _enabled = true


func deactivate() -> void:
    _enabled = false


func is_active() -> bool:
    return _enabled


func is_dragged() -> bool:
    return _grabbed_draggable == self

