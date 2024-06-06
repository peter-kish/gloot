@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_item.svg")
class_name CtrlInventoryItem
extends "res://addons/gloot/ui/ctrl_draggable.gd"

signal activated
signal clicked
signal context_activated

const Utils = preload("res://addons/gloot/core/utils.gd")

var item: InventoryItem :
    set(new_item):
        if item == new_item:
            return

        _disconnect_item_signals()
        _connect_item_signals(new_item)

        item = new_item
        if item:
            _texture = item.get_texture()
            activate()
        else:
            _texture = null
            deactivate()
        _update_stack_size()
@export_group("Icon Behavior", "icon_")
@export var icon_stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_SCALE :
    set(new_stretch_mode):
        if icon_stretch_mode == new_stretch_mode:
            return
        icon_stretch_mode = new_stretch_mode
        if is_instance_valid(_texture_rect):
            _texture_rect.stretch_mode = icon_stretch_mode
var _texture: Texture2D :
    set(new_texture):
        if new_texture == _texture:
            return
        _texture = new_texture
        _update_texture()
var _texture_rect: TextureRect
var _stack_size_label: Label
static var _stored_preview_size: Vector2
static var _stored_preview_offset: Vector2


func _connect_item_signals(new_item: InventoryItem) -> void:
    if new_item == null:
        return
    Utils.safe_connect(new_item.property_changed, _on_item_property_changed)


func _disconnect_item_signals() -> void:
    if !is_instance_valid(item):
        return
    Utils.safe_disconnect(item.property_changed, _on_item_property_changed)


func _on_item_property_changed(_property: String) -> void:
    _refresh()


func _get_item_position() -> Vector2:
    if is_instance_valid(item) && item.get_inventory():
        return item.get_inventory().get_item_position(item)
    return Vector2(0, 0)


func _ready() -> void:
    _texture_rect = TextureRect.new()
    _texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _texture_rect.stretch_mode = icon_stretch_mode
    _stack_size_label = Label.new()
    _stack_size_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _stack_size_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _stack_size_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
    add_child(_texture_rect)
    add_child(_stack_size_label)

    resized.connect(func():
        _texture_rect.size = size
        _stack_size_label.size = size
    )

    if item == null:
        deactivate()

    _refresh()


func _update_texture() -> void:
    if !is_instance_valid(_texture_rect):
        return
    _texture_rect.texture = _texture
    if is_instance_valid(item) && GridConstraint.is_item_rotated(item):
        _texture_rect.size = Vector2(size.y, size.x)
        if GridConstraint.is_item_rotation_positive(item):
            _texture_rect.position = Vector2(_texture_rect.size.y, 0)
            _texture_rect.rotation = PI/2
        else:
            _texture_rect.position = Vector2(0, _texture_rect.size.x)
            _texture_rect.rotation = -PI/2

    else:
        _texture_rect.size = size
        _texture_rect.position = Vector2.ZERO
        _texture_rect.rotation = 0


func _update_stack_size() -> void:
    if !is_instance_valid(_stack_size_label):
        return
    if !is_instance_valid(item):
        _stack_size_label.text = ""
        return
    var stack_size: int = Inventory.get_item_stack_size(item).count
    if stack_size <= 1:
        _stack_size_label.text = ""
    else:
        _stack_size_label.text = "%d" % stack_size
    _stack_size_label.size = size


func _refresh() -> void:
    _update_texture()
    _update_stack_size()


func create_preview() -> Control:
    var preview = CtrlInventoryItem.new()
    preview.item = item
    preview._texture = _texture
    preview.size = size
    preview.icon_stretch_mode = icon_stretch_mode
    return preview


func _gui_input(event: InputEvent) -> void:
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
