extends "res://addons/gloot/ui/ctrl_dragable.gd"

const CtrlInventoryItemRect = preload("res://addons/gloot/ui/ctrl_inventory_item_rect.gd")
const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

signal activated
signal clicked
signal context_activated

var item: InventoryItem :
    set(new_item):
        if item == new_item:
            return

        _disconnect_item_signals()
        _connect_item_signals(new_item)

        item = new_item
        if item:
            texture = item.get_texture()
            activate()
        else:
            texture = null
            deactivate()
        _update_stack_size()
var texture: Texture2D :
    set(new_texture):
        if new_texture == texture:
            return
        texture = new_texture
        _update_texture()
var stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_SCALE :
    set(new_stretch_mode):
        if stretch_mode == new_stretch_mode:
            return
        stretch_mode = new_stretch_mode
        if is_instance_valid(_texture_rect):
            _texture_rect.stretch_mode = stretch_mode
var item_slot: ItemSlot
var _texture_rect: TextureRect
var _stack_size_label: Label
static var _stored_preview_size: Vector2
static var _stored_preview_offset: Vector2


func _connect_item_signals(new_item: InventoryItem) -> void:
    if new_item == null:
        return

    if !new_item.protoset_changed.is_connected(_refresh):
        new_item.protoset_changed.connect(_refresh)
    if !new_item.prototype_id_changed.is_connected(_refresh):
        new_item.prototype_id_changed.connect(_refresh)
    if !new_item.property_changed.is_connected(_on_item_property_changed):
        new_item.property_changed.connect(_on_item_property_changed)


func _disconnect_item_signals() -> void:
    if !is_instance_valid(item):
        return

    if item.protoset_changed.is_connected(_refresh):
        item.protoset_changed.disconnect(_refresh)
    if item.prototype_id_changed.is_connected(_refresh):
        item.prototype_id_changed.disconnect(_refresh)
    if item.property_changed.is_connected(_on_item_property_changed):
        item.property_changed.disconnect(_on_item_property_changed)


func _on_item_property_changed(property_name: String) -> void:
    var relevant_properties = [
        StacksConstraint.KEY_STACK_SIZE, 
        GridConstraint.KEY_WIDTH,
        GridConstraint.KEY_HEIGHT,
        GridConstraint.KEY_SIZE,
        GridConstraint.KEY_ROTATED,
        GridConstraint.KEY_GRID_POSITION,
        InventoryItem.KEY_IMAGE,
    ]
    if property_name in relevant_properties:
        _refresh()


func _ready() -> void:
    _texture_rect = TextureRect.new()
    _texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _texture_rect.stretch_mode = stretch_mode
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
    _texture_rect.texture = texture
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
    var stack_size: int = StacksConstraint.get_item_stack_size(item)
    if stack_size <= 1:
        _stack_size_label.text = ""
    else:
        _stack_size_label.text = "%d" % stack_size
    _stack_size_label.size = size


func _refresh() -> void:
    _update_texture()
    _update_stack_size()


func create_preview() -> Control:
    var preview = CtrlInventoryItemRect.new()
    preview.item = item
    preview.texture = texture
    preview.size = size
    preview.stretch_mode = stretch_mode
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

