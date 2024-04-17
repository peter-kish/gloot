@tool
extends Control

signal dragable_dropped(dragable, position)

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")


func activate() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS


func deactivate() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_active() -> bool:
    return (mouse_filter != Control.MOUSE_FILTER_IGNORE)


func _can_drop_data(at_position: Vector2, data) -> bool:
    return data is CtrlDragable


func _drop_data(at_position: Vector2, data) -> void:
    var local_pos := CtrlDragable.get_grab_offset() / get_global_transform().get_scale()
    dragable_dropped.emit(data, at_position - local_pos)
    CtrlDragable.dragable_dropped.emit(data, self, at_position - local_pos)

