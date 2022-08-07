class_name CtrlInventoryItemRect
extends Control

signal grabbed
signal activated

var item: InventoryItem setget _set_item
var ctrl_inventory
var texture: Texture setget _set_texture
var selected: bool = false setget _set_selected
var selection_bg_color: Color = Color.gray setget _set_selection_bg_color


func _set_texture(new_texture: Texture) -> void:
    texture = new_texture
    update()


func _set_selected(new_selected: bool) -> void:
    selected = new_selected
    update()


func _set_selection_bg_color(new_selection_bg_color: Color) -> void:
    selection_bg_color = new_selection_bg_color
    update()


func _set_item(new_item: InventoryItem) -> void:
    item = new_item
    if item && ctrl_inventory:
        var texture_path = item.get_property(CtrlInventory.KEY_IMAGE)
        if texture_path:
            _set_texture(load(texture_path))
        var item_size = _get_item_size()
        var item_pos = _get_item_position()
        rect_size = Vector2(item_size.x * ctrl_inventory.field_dimensions.x, \
            item_size.y * ctrl_inventory.field_dimensions.y)
        rect_position = Vector2(item_pos.x * ctrl_inventory.field_dimensions.x, \
            item_pos.y * ctrl_inventory.field_dimensions.y)


func _get_item_size() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_size(item)
    return Vector2(1, 1)


func _get_item_position() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_position(item)
    return Vector2(0, 0)


func _ready() -> void:
    if item && ctrl_inventory:
        var item_size = _get_item_size()
        var item_pos = _get_item_position()
        rect_size = Vector2(item_size.x * ctrl_inventory.field_dimensions.x, \
            item_size.y * ctrl_inventory.field_dimensions.y)
        rect_min_size = rect_size
        rect_position = Vector2(item_pos.x * ctrl_inventory.field_dimensions.x, \
            item_pos.y * ctrl_inventory.field_dimensions.y)


func _draw() -> void:
    var rect = Rect2(Vector2.ZERO, rect_size)

    if selected:
        draw_rect(rect, Color.gray, true)

    if texture:
        var src_rect: Rect2 = Rect2(0, 0, texture.get_width(), texture.get_height())
        draw_texture_rect_region(texture, rect, src_rect)
    else:
        draw_rect(rect, Color.white, false)


func _input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton):
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.button_index != BUTTON_LEFT:
        return

    if mb_event.doubleclick:
        if get_global_rect().has_point(get_global_mouse_position()):
            emit_signal("activated", self)
    elif mb_event.is_pressed():
        if get_global_rect().has_point(get_global_mouse_position()):
            var offset: Vector2 = get_global_mouse_position() - get_global_rect().position
            emit_signal("grabbed", self, offset)
