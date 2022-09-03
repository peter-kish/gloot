class_name CtrlInventoryGridEx
extends CtrlInventoryGrid
tool

export(Texture) var field_background: Texture setget _set_field_background
export(Texture) var field_highlighted_background: Texture setget _set_field_highlighted_background
export(bool) var stretch_background_sprites: bool = true setget _set_stretch_background_sprites
var _field_background_grid: Control
var _field_backgrounds: Array


func _set_field_background(new_field_background: Texture) -> void:
    field_background = new_field_background
    _refresh()


func _set_field_highlighted_background(new_field_highlighted_background: Texture) -> void:
    field_highlighted_background = new_field_highlighted_background
    _refresh()


func _set_stretch_background_sprites(new_value: bool) -> void:
    stretch_background_sprites = new_value
    _refresh()


func _refresh() -> void:
    ._refresh()
    refresh_field_background_grid()


func refresh_field_background_grid() -> void:
    if _field_background_grid:
        remove_child(_field_background_grid)
        _field_background_grid.queue_free()
        _field_background_grid = null
        _field_backgrounds = []

    if !inventory || !field_background:
        return

    _field_background_grid = Control.new()
    add_child(_field_background_grid)
    move_child(_field_background_grid, 0)

    for i in range(inventory.size.x):
        _field_backgrounds.append([])
        for j in range(inventory.size.y):
            var field_texture_rect: TextureRect = TextureRect.new()
            field_texture_rect.texture = field_background
            if stretch_background_sprites:
                var sprite_size: Vector2 = field_background.get_size()
                field_texture_rect.rect_scale = Vector2(field_dimensions.x / sprite_size.x, \
                    field_dimensions.y / sprite_size.y)
            else:
                field_texture_rect.rect_size = field_dimensions
            field_texture_rect.rect_position = _get_field_position(Vector2(i, j))
            _field_background_grid.add_child(field_texture_rect)
            _field_backgrounds[i].append(field_texture_rect)


func _input(event) -> void:
    if event is InputEventMouseMotion:
        for i in range(inventory.size.x):
            for j in range(inventory.size.y):
                var field_texture_rect = _field_backgrounds[i][j]
                if _is_field_highlighted(Vector2(i, j)) && field_highlighted_background:
                    field_texture_rect.texture = field_highlighted_background
                else:
                    field_texture_rect.texture = field_background


func _is_field_highlighted(field_coords: Vector2) -> bool:
    var item: InventoryItem = _get_item_on_field(field_coords)
    if item:
        return _is_item_highlighted(item)

    var mouse_pos: Vector2 = get_global_mouse_position()
    var rect: Rect2 = Rect2(_get_global_field_position(field_coords), field_dimensions)
    return rect.has_point(mouse_pos)


func _get_item_on_field(field_coords: Vector2) -> InventoryItem:
    if !inventory:
        return null

    for item in inventory.get_items():
        var item_coords: Vector2 = inventory.get_item_position(item)
        var item_size: Vector2 = inventory.get_item_size(item)
        var rect: Rect2 = Rect2(item_coords, item_size)
        if rect.has_point(field_coords):
            return item

    return null


func _is_item_highlighted(item: InventoryItem) -> bool:
    var item_coords: Vector2 = inventory.get_item_position(item)
    var item_size: Vector2 = inventory.get_item_size(item)
    var item_global_pos: Vector2 = _get_global_field_position(item_coords)
    var item_global_size: Vector2 = _get_streched_item_sprite_size(item)
    if !stretch_item_sprites:
        item_global_size = Vector2(field_dimensions.x * item_size.x, \
            field_dimensions.y * item_size.y)

    return Rect2(item_global_pos, item_global_size).has_point(get_global_mouse_position())
