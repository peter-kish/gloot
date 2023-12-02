class_name CtrlInventoryItemRect
extends "res://addons/gloot/ui/ctrl_dragable.gd"

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")

signal activated

var item: InventoryItem :
    get:
        return item
    set(new_item):
        item = new_item
        if item:
            texture = item.get_texture()
var texture: Texture2D :
    get:
        return texture
    set(new_texture):
        texture = new_texture
        if drag_preview != null:
            drag_preview.texture = texture
        queue_redraw()
var selected: bool = false :
    get:
        return selected
    set(new_selected):
        selected = new_selected
        queue_redraw()
var selection_bg_color: Color = Color.GRAY :
    get:
        return selection_bg_color
    set(new_selection_bg_color):
        selection_bg_color = new_selection_bg_color
        queue_redraw()
var item_slot: ItemSlot


func _get_item_size() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_size(item)
    return Vector2(1, 1)


func _get_item_position() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_position(item)
    return Vector2(0, 0)


func _ready() -> void:
    drag_preview = TextureRect.new()
    drag_preview.texture = texture
    drag_preview.size = size
    drag_preview.resized.connect(func(): drag_preview.size = size)


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
    else:
        draw_rect(rect, Color.WHITE, false)


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
