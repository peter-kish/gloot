class_name CtrlInventoryGridEx
extends CtrlInventoryGrid
tool

export(Texture) var field_background: Texture setget _set_field_background
export(bool) var stretch_background_sprites: bool = true setget _set_stretch_background_sprites
var _field_background_grid: Control


func _set_field_background(new_field_background: Texture) -> void:
    field_background = new_field_background
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

    if !inventory || !field_background:
        return

    _field_background_grid = Control.new()
    add_child(_field_background_grid)
    move_child(_field_background_grid, 0)

    for i in range(inventory.size.x):
        for j in range(inventory.size.y):
            var field: TextureRect = TextureRect.new()
            field.texture = field_background
            if stretch_background_sprites:
                var sprite_size: Vector2 = field_background.get_size()
                field.rect_scale = Vector2(field_dimensions.x / sprite_size.x, \
                    field_dimensions.y / sprite_size.y)
            else:
                field.rect_size = field_dimensions
            field.rect_position = _get_field_position(Vector2(i, j))
            _field_background_grid.add_child(field)

