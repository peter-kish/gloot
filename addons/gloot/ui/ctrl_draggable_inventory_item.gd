@tool
extends Control

signal activated
signal clicked
signal context_activated
signal grabbed(position)
signal dropped(zone, position)

const CtrlDraggable = preload("res://addons/gloot/ui/ctrl_draggable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

var item: InventoryItem :
    set(new_item):
        if item == new_item:
            return

        item = new_item
        if is_instance_valid(_ctrl_inventory_item):
            _ctrl_inventory_item.item = item
        if is_instance_valid(_ctrl_draggable):
            if item:
                _ctrl_draggable.activate()
            else:
                _ctrl_draggable.deactivate()
var icon_stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_SCALE :
    set(new_stretch_mode):
        if icon_stretch_mode == new_stretch_mode:
            return
        icon_stretch_mode = new_stretch_mode
        if is_instance_valid(_ctrl_inventory_item):
            _ctrl_inventory_item.stretch_mode = icon_stretch_mode
var ctrl_inventory_item_scene: PackedScene = null
var _ctrl_draggable: CtrlDraggable
var _ctrl_inventory_item: CtrlInventoryItemBase


func _ready() -> void:
    if ctrl_inventory_item_scene == null:
        _ctrl_inventory_item = CtrlInventoryItem.new()
    else:
        _ctrl_inventory_item = ctrl_inventory_item_scene.instantiate()
    _ctrl_inventory_item.name = "CtrlInventoryItemBase"
    _ctrl_inventory_item.size = size
    _ctrl_inventory_item.item = item
    _ctrl_inventory_item.icon_stretch_mode = icon_stretch_mode

    _ctrl_draggable = CtrlDraggable.new()
    _ctrl_draggable.name = "CtrlDraggable"
    _ctrl_draggable.size = size
    _ctrl_draggable.create_preview = func(): return _create_preview()
    _ctrl_draggable.gui_input.connect(_on_draggable_gui_event)
    _ctrl_draggable.metadata = self
    _ctrl_draggable.grabbed.connect(_on_grabbed)
    _ctrl_draggable.dropped.connect(_on_dropped)
    _ctrl_draggable.mouse_entered.connect(func(): mouse_entered.emit())
    _ctrl_draggable.mouse_exited.connect(func(): mouse_exited.emit())

    add_child(_ctrl_inventory_item)
    add_child(_ctrl_draggable)

    resized.connect(func():
        _ctrl_inventory_item.size = size
        _ctrl_draggable.size = size
    )

    if item == null:
        _ctrl_draggable.deactivate()


func _on_grabbed(position: Vector2) -> void:
    grabbed.emit(position)


func _on_dropped(zone: CtrlDropZone, position: Vector2) -> void:
    dropped.emit(zone, position)


func _create_preview() -> Control:
    var preview = CtrlInventoryItem.new()
    preview.item = item
    preview.size = size
    preview.icon_stretch_mode = icon_stretch_mode
    return preview


func _on_draggable_gui_event(event: InputEvent) -> void:
    if !(event is InputEventMouseButton):
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.button_index == MOUSE_BUTTON_LEFT:
        if mb_event.double_click:
            activated.emit()
        else:
            clicked.emit()
    elif mb_event.button_index == MOUSE_BUTTON_MASK_RIGHT:
        context_activated.emit()
