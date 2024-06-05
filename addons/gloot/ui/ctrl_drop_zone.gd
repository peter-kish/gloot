@tool
extends Control

signal draggable_dropped(draggable, position)

const CtrlDraggable = preload("res://addons/gloot/ui/ctrl_draggable.gd")


func activate() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS


func deactivate() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_active() -> bool:
    return (mouse_filter != Control.MOUSE_FILTER_IGNORE)


func _can_drop_data(at_position: Vector2, data) -> bool:
    return data is CtrlDraggable


func _drop_data(at_position: Vector2, data) -> void:
    var local_offset := CtrlDraggable.get_grab_offset_local_to(self)
    draggable_dropped.emit(data, at_position - local_offset)
    CtrlDraggable.draggable_dropped.emit(data, self, at_position - local_offset)


