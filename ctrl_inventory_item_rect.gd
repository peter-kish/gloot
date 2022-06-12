class_name CtrlInventoryItemRect
extends Control

signal grabbed;

var item: InventoryItem setget _set_item;
var ctrl_inventory;
var texture: Texture;


func _set_item(new_item: InventoryItem) -> void:
    item = new_item;
    if item && ctrl_inventory:
        var texture_path = item.get_property("image");
        if texture_path:
            texture = load(texture_path);
        var item_size = _get_item_size();
        var item_pos = _get_item_position();
        rect_size = Vector2(item_size.x * ctrl_inventory.field_dimensions.x, \
            item_size.y * ctrl_inventory.field_dimensions.y);
        rect_position = Vector2(item_pos.x * ctrl_inventory.field_dimensions.x, \
            item_pos.y * ctrl_inventory.field_dimensions.y);


func _get_item_size() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_size(item);
    return Vector2(1, 1);


func _get_item_position() -> Vector2:
    if item && item.get_inventory():
        return item.get_inventory().get_item_position(item);
    return Vector2(0, 0);


func _ready() -> void:
    if item && ctrl_inventory:
        var item_size = _get_item_size();
        var item_pos = _get_item_position();
        rect_size = Vector2(item_size.x * ctrl_inventory.field_dimensions.x, \
            item_size.y * ctrl_inventory.field_dimensions.y);
        rect_min_size = rect_size;
        rect_position = Vector2(item_pos.x * ctrl_inventory.field_dimensions.x, \
            item_pos.y * ctrl_inventory.field_dimensions.y);


func _draw() -> void:
    var rect = Rect2(Vector2.ZERO, rect_size);
    if texture:
        var src_rect: Rect2 = Rect2(0, 0, texture.get_width(), texture.get_height());
        draw_texture_rect_region(texture, rect, src_rect);
    else:
        draw_rect(rect, Color.white, false);


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mb_event: InputEventMouseButton = event;
        if mb_event.is_pressed() && mb_event.button_index == BUTTON_LEFT:
            if get_global_rect().has_point(get_global_mouse_position()):
                var offset: Vector2 = get_global_mouse_position() - get_global_rect().position;
                emit_signal("grabbed", self, offset);
