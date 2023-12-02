@tool
extends Control

signal grabbed(position)
signal dropped(zone, position)

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

static var _grabbed_dragable: CtrlDragable = null
static var _grab_offset: Vector2


static func grab(dragable: CtrlDragable) -> void:
    _grabbed_dragable = dragable
    _grab_offset = dragable.get_global_mouse_position() - dragable.global_position

    dragable.grabbed.emit(_grab_offset)
    dragable.drag_start()


static func release() -> void:
    _drop(null)


static func release_on(zone: CtrlDropZone) -> void:
    _drop(zone)


static func _drop(zone: CtrlDropZone) -> void:
    var grabbed_dragable := _grabbed_dragable
    var grab_offset := _grab_offset
    _grabbed_dragable = null
    _grab_offset = Vector2.ZERO
    grabbed_dragable.mouse_filter = Control.MOUSE_FILTER_PASS
    var local_drop_position := Vector2.ZERO
    if zone != null:
        local_drop_position = zone.get_local_mouse_position() - grab_offset

    grabbed_dragable.drag_end()
    grabbed_dragable.dropped.emit(zone, local_drop_position)


static func get_grabbed_dragable() -> CtrlDragable:
    return _grabbed_dragable


static func get_grab_offset() -> Vector2:
    return _grab_offset


func drag_start() -> void:
    pass


func drag_end() -> void:
    pass


func _gui_input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton):
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.button_index != MOUSE_BUTTON_LEFT:
        return

    if mb_event.is_pressed():
        grab(self)
        mouse_filter = Control.MOUSE_FILTER_IGNORE

