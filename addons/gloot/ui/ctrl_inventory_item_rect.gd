class_name CtrlInventoryItemRect
extends "res://addons/gloot/ui/ctrl_dragable.gd"

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")

signal activated

var item: InventoryItem :
    get:
        return item
    set(new_item):
        if item == new_item:
            return

        _disconnect_item_signals()
        _connect_item_signals(new_item)

        item = new_item
        if item:
            texture = item.get_texture()
        else:
            texture = null
var texture: Texture2D :
    get:
        return texture
    set(new_texture):
        if new_texture == texture:
            return
        texture = new_texture
        if texture != null:
            size = texture.get_size()
        queue_redraw()
var selected: bool = false :
    get:
        return selected
    set(new_selected):
        if new_selected == selected:
            return
        selected = new_selected
        queue_redraw()
var selection_bg_color: Color = Color.GRAY :
    get:
        return selection_bg_color
    set(new_selection_bg_color):
        if new_selection_bg_color == selection_bg_color:
            return
        selection_bg_color = new_selection_bg_color
        queue_redraw()
var item_slot: ItemSlot
static var _stored_preview_size: Vector2
static var _stored_preview_offset: Vector2


func _connect_item_signals(new_item: InventoryItem) -> void:
    if new_item == null:
        return

    if !new_item.protoset_changed.is_connected(queue_redraw):
        new_item.protoset_changed.connect(queue_redraw)
    if !new_item.prototype_id_changed.is_connected(queue_redraw):
        new_item.prototype_id_changed.connect(queue_redraw)
    if !new_item.properties_changed.is_connected(queue_redraw):
        new_item.properties_changed.connect(queue_redraw)


func _disconnect_item_signals() -> void:
    if item == null:
        return

    if item.protoset_changed.is_connected(queue_redraw):
        item.protoset_changed.disconnect(queue_redraw)
    if item.prototype_id_changed.is_connected(queue_redraw):
        item.prototype_id_changed.disconnect(queue_redraw)
    if item.properties_changed.is_connected(queue_redraw):
        item.properties_changed.disconnect(queue_redraw)


func _get_item_size() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_size(item)
    return Vector2(1, 1)


func _get_item_position() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_position(item)
    return Vector2(0, 0)


func _ready() -> void:
    drag_preview = CtrlInventoryItemRect.new()


func drag_start() -> void:
    if drag_preview != null:
        drag_preview.item = item
        drag_preview.texture = texture
        drag_preview.size = size
    super.drag_start()


static func override_preview_size(s: Vector2) -> void:
    if CtrlDragable._grabbed_dragable == null:
        return
    var _grabbed_ctrl := (CtrlDragable._grabbed_dragable as CtrlInventoryItemRect)
    if _grabbed_ctrl.item == null || _grabbed_ctrl.drag_preview == null:
        return
    _stored_preview_size = _grabbed_ctrl.drag_preview.size
    _stored_preview_offset = CtrlDragable._grab_offset
    CtrlDragable._grab_offset *= s/_grabbed_ctrl.drag_preview.size
    _grabbed_ctrl.drag_preview.size = s


static func restore_preview_size() -> void:
    if CtrlDragable._grabbed_dragable == null:
        return
    var _grabbed_ctrl := (CtrlDragable._grabbed_dragable as CtrlInventoryItemRect)
    if _grabbed_ctrl.item == null || _grabbed_ctrl.drag_preview == null:
        return
    _grabbed_ctrl.drag_preview.size = _stored_preview_size
    CtrlDragable._grab_offset = _stored_preview_offset


func _draw() -> void:
    if is_dragged():
        return
    var rect = Rect2(Vector2.ZERO, size)
    _draw_selection(rect)
    _draw_texture(rect)
    _draw_stack_size(rect)


func _draw_selection(rect: Rect2):
    if selected:
        draw_rect(rect, selection_bg_color, true)


func _draw_texture(rect: Rect2):
    if texture:
        var src_rect: Rect2 = Rect2(0, 0, texture.get_width(), texture.get_height())
        draw_texture_rect_region(texture, rect, src_rect)


func _draw_stack_size(rect: Rect2):
    if item == null:
        return

    var stack_size: int = StacksConstraint.get_item_stack_size(item)
    if stack_size <= 1:
        return

    var default_font := ThemeDB.fallback_font
    var default_font_size := ThemeDB.fallback_font_size
    var text = str(stack_size)
    draw_string(
        default_font,
        rect.position + Vector2(0, rect.size.y),
        text,
        HORIZONTAL_ALIGNMENT_RIGHT,
        rect.size.x, 
        default_font_size
    )


func _gui_input(event: InputEvent) -> void:
    super._gui_input(event)
    if !(event is InputEventMouseButton):
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.button_index != MOUSE_BUTTON_LEFT:
        return

    if mb_event.double_click:
        if get_global_rect().has_point(get_global_mouse_position()):
            activated.emit()
