@tool
extends Control

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

# Somewhat hacky way to do static signals:
# https://stackoverflow.com/questions/77026156/how-to-write-a-static-event-emitter-in-gdscript/77026952#77026952

static var dragable_grabbed: Signal = (func():
    (CtrlDragable as Object).add_user_signal("dragable_grabbed")
    return Signal(CtrlDragable, "dragable_grabbed")
).call()

static var dragable_dropped: Signal = (func():
    (CtrlDragable as Object).add_user_signal("dragable_dropped")
    return Signal(CtrlDragable, "dragable_dropped")
).call()

signal grabbed(position)
signal dropped(zone, position)

static var _grabbed_dragable: CtrlDragable = null
static var _grab_offset: Vector2

var drag_preview: Control
var _preview_node := Node2D.new()
var drag_z_index := 1


static func grab(dragable: CtrlDragable) -> void:
    _grabbed_dragable = dragable
    _grab_offset = dragable.get_global_mouse_position() - dragable.global_position

    dragable.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dragable.grabbed.emit(_grab_offset)
    dragable_grabbed.emit(dragable, _grab_offset)
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
    dragable_dropped.emit(grabbed_dragable, zone, local_drop_position)


static func get_grabbed_dragable() -> CtrlDragable:
    return _grabbed_dragable


static func get_grab_offset() -> Vector2:
    return _grab_offset


func drag_start() -> void:
    if drag_preview == null:
        return

    drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
    drag_preview.global_position = get_global_mouse_position() - get_grab_offset()
    add_child(_preview_node)
    _preview_node.add_child(drag_preview)
    _preview_node.z_index = drag_z_index


func drag_end() -> void:
    if drag_preview == null:
        return

    _preview_node.remove_child(drag_preview)
    remove_child(_preview_node)
    drag_preview.mouse_filter = Control.MOUSE_FILTER_PASS


func _process(_delta) -> void:
    if drag_preview:
        drag_preview.global_position = get_global_mouse_position() - get_grab_offset()


func _gui_input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton):
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.button_index != MOUSE_BUTTON_LEFT:
        return

    if mb_event.is_pressed():
        grab(self)


func is_dragged() -> bool:
    return _grabbed_dragable == self

