@tool
extends Control

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

# Somewhat hacky way to do static signals:
# https://stackoverflow.com/questions/77026156/how-to-write-a-static-event-emitter-in-gdscript/77026952#77026952

static var dragable_grabbed: Signal = (func():
    if (CtrlDragable as Object).has_user_signal("dragable_grabbed"):
        return (CtrlDragable as Object).dragable_grabbed
    (CtrlDragable as Object).add_user_signal("dragable_grabbed")
    return Signal(CtrlDragable, "dragable_grabbed")
).call()

static var dragable_dropped: Signal = (func():
    if (CtrlDragable as Object).has_user_signal("dragable_dropped"):
        return (CtrlDragable as Object).dragable_dropped
    (CtrlDragable as Object).add_user_signal("dragable_dropped")
    return Signal(CtrlDragable, "dragable_dropped")
).call()

signal grabbed(position)
signal dropped(zone, position)
signal clicked

# Embedded Windows are placed on layer 1024. CanvasItems on layers 1025 and higher appear in front of embedded windows.
# (https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html#description)
const EMBEDDED_WINDOWS_LAYER = 1024

static var _grabbed_dragable: CtrlDragable = null
static var _grab_offset: Vector2

var drag_preview: Control
var _preview_canvas_layer := CanvasLayer.new()
var drag_z_index := 1
var enabled: bool = true
var _show_queued := false
var _clicked := false
var _click_position := Vector2.ZERO


static func grab(dragable: CtrlDragable) -> void:
    _grabbed_dragable = dragable
    _grab_offset = dragable.get_grab_position()

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
    grabbed_dragable.mouse_filter = Control.MOUSE_FILTER_PASS
    var local_drop_position := Vector2.ZERO
    if zone != null:
        local_drop_position = zone.get_drop_position()
    else:
        local_drop_position = _grabbed_dragable.get_drop_position()

    _grabbed_dragable = null
    _grab_offset = Vector2.ZERO
    grabbed_dragable.drag_end()
    grabbed_dragable.dropped.emit(zone, local_drop_position)
    dragable_dropped.emit(grabbed_dragable, zone, local_drop_position)


func get_drop_position() -> Vector2:
    return get_local_mouse_position() - (get_grab_offset() / get_global_transform().get_scale())


static func get_grabbed_dragable() -> CtrlDragable:
    return _grabbed_dragable


static func get_grab_offset() -> Vector2:
    return _grab_offset


func get_grab_position() -> Vector2:
    return get_local_mouse_position() * get_global_transform().get_scale()


func drag_start() -> void:
    if !is_instance_valid(drag_preview):
        return

    drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
    drag_preview.global_position = _get_global_preview_position()
    get_viewport().add_child(_preview_canvas_layer)
    _preview_canvas_layer.add_child(drag_preview)
    # Make sure the preview is drawn above the embedded windows
    _preview_canvas_layer.layer = EMBEDDED_WINDOWS_LAYER + 1
    hide()


func _get_global_preview_position() -> Vector2:
    return get_global_mouse_position() - _grab_offset


func drag_end() -> void:
    if !is_instance_valid(drag_preview):
        return

    _preview_canvas_layer.remove_child(drag_preview)
    _preview_canvas_layer.get_parent().remove_child(_preview_canvas_layer)
    drag_preview.mouse_filter = Control.MOUSE_FILTER_PASS
    # HACK: Queue the show() call for later to avoid glitching
    _queue_show()


func _queue_show() -> void:
    _show_queued = true


func _notification(what) -> void:
    if what == NOTIFICATION_PREDELETE && is_instance_valid(_preview_canvas_layer):
        _preview_canvas_layer.queue_free()


func _process(_delta) -> void:
    if is_instance_valid(drag_preview):
        drag_preview.scale = get_global_transform().get_scale()
        drag_preview.global_position = _get_global_preview_position()
    if _show_queued:
        _show_queued = false
        show()


func _gui_input(event: InputEvent) -> void:
    if !enabled:
        return

    if event is InputEventMouseMotion:
        _handle_mouse_motion(event as InputEventMouseMotion)
    elif event is InputEventMouseButton:
        _handle_mouse_button(event as InputEventMouseButton)


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
    var deadzone_radius = ProjectSettings.get_setting("gloot/item_dragging_deadzone_radius", 8.0)
    if _clicked && (get_local_mouse_position() - _click_position).length() > deadzone_radius:
        _clicked = false
        grab(self)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
    if event.button_index != MOUSE_BUTTON_LEFT:
        return

    if event.is_pressed():
        _clicked = true
        _click_position = get_local_mouse_position()
        clicked.emit()
    else:
        _clicked = false


func activate() -> void:
    enabled = true


func deactivate() -> void:
    enabled = false


func is_dragged() -> bool:
    return _grabbed_dragable == self

