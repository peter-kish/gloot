@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_item.svg")
class_name CtrlInventoryItem
extends CtrlInventoryItemBase
## Control node for displaying inventory items.
##
## Displays an `InventoryItem` icon and its stack size. Consists of a `TextureRect` (the icon) a `Label` (the stack
## size).

const _Utils = preload("res://addons/gloot/core/utils.gd")

var _texture_rect: TextureRect
var _stack_size_label: Label
var _old_item: InventoryItem = null


func _connect_item_signals(new_item: InventoryItem) -> void:
    if !is_instance_valid(new_item):
        return
    _Utils.safe_connect(new_item.property_changed, _on_item_property_changed)


func _disconnect_item_signals(old_item: InventoryItem) -> void:
    if !is_instance_valid(old_item):
        return
    _Utils.safe_disconnect(old_item.property_changed, _on_item_property_changed)


func _on_item_property_changed(_property: String) -> void:
    _refresh()


func _get_item_position() -> Vector2:
    if is_instance_valid(item) && item.get_inventory():
        return item.get_inventory().get_item_position(item)
    return Vector2(0, 0)


func _ready() -> void:
    item_changed.connect(_on_item_changed)
    icon_stretch_mode_changed.connect(_on_icon_stretch_mode_changed)

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

    _refresh()


func _on_item_changed() -> void:
    _disconnect_item_signals(_old_item)
    _old_item = item
    _connect_item_signals(item)
    _refresh()


func _on_icon_stretch_mode_changed() -> void:
    if is_instance_valid(_texture_rect):
        _texture_rect.stretch_mode = icon_stretch_mode


func _update_texture() -> void:
    if !is_instance_valid(_texture_rect):
        return

    if is_instance_valid(item):
        _texture_rect.texture = item.get_texture()
    else:
        _texture_rect.texture = null
        return

    if is_instance_valid(item) && GridConstraint.is_item_rotated(item):
        _texture_rect.size = Vector2(size.y, size.x)
        if GridConstraint.is_item_rotation_positive(item):
            _texture_rect.position = Vector2(_texture_rect.size.y, 0)
            _texture_rect.rotation = PI / 2
        else:
            _texture_rect.position = Vector2(0, _texture_rect.size.x)
            _texture_rect.rotation = -PI / 2

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
    var stack_size: int = item.get_stack_size()
    if stack_size <= 1:
        _stack_size_label.text = ""
    else:
        _stack_size_label.text = "%d" % stack_size
    _stack_size_label.size = size


func _refresh() -> void:
    _update_texture()
    _update_stack_size()
