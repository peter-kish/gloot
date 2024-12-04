@tool
extends Control

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

@onready var panel = %Panel
@onready var panel2 = %Panel2
@onready var dragable: CtrlDragable = %Dragable


# Called when the node enters the scene tree for the first time.
func _ready():
    panel.dragable_dropped.connect(_on_dragable_dropped_on_zone.bind(panel))
    panel2.dragable_dropped.connect(_on_dragable_dropped_on_zone.bind(panel2))
    dragable.grabbed.connect(_on_dragable_grabbed.bind(dragable))
    dragable.dropped.connect(_on_dragable_dropped.bind(dragable))


func _on_dragable_dropped_on_zone(control: Control, drop_position: Vector2, dropped_panel: Panel) -> void:
    print("%s dropped on %s at %s" % [control.name, dropped_panel.name, drop_position])


func _on_dragable_grabbed(pos: Vector2, grabbed_dragable: CtrlDragable) -> void:
    print("%s grabbed at %s" % [grabbed_dragable.name, str(pos)])


func _on_dragable_dropped(drop_zone: CtrlDropZone, pos: Vector2, grabbed_dragable: CtrlDragable) -> void:
    if drop_zone:
        print("%s dropped at %s on %s" % [grabbed_dragable.name, str(pos), drop_zone.name])
    else:
        print("%s dropped at %s" % [grabbed_dragable.name, str(pos)])
