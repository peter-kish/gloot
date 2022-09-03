class_name CtrlInventoryGridEx
extends CtrlInventoryGrid
tool

export(StyleBox) var field_style: StyleBox setget _set_field_style
export(StyleBox) var field_highlighted_style: StyleBox setget _set_field_highlighted_style
export(StyleBox) var field_selected_style: StyleBox setget _set_field_selected_style
var _field_background_grid: Control
var _field_backgrounds: Array


func _set_field_style(new_field_style: StyleBox) -> void:
    field_style = new_field_style
    _refresh()


func _set_field_highlighted_style(new_field_highlighted_style: StyleBox) -> void:
    field_highlighted_style = new_field_highlighted_style
    _refresh()


func _set_field_selected_style(new_field_selected_style: StyleBox) -> void:
    field_selected_style = new_field_selected_style
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

    if !inventory:
        return

    _field_background_grid = Control.new()
    add_child(_field_background_grid)
    move_child(_field_background_grid, 0)

    for i in range(inventory.size.x):
        _field_backgrounds.append([])
        for j in range(inventory.size.y):
            var field_panel: Panel = Panel.new()
            _set_field_panel_style(field_panel, field_style)
            field_panel.rect_size = field_dimensions
            field_panel.rect_position = _get_field_position(Vector2(i, j))
            _field_background_grid.add_child(field_panel)
            _field_backgrounds[i].append(field_panel)


func _set_field_panel_style(field_panel: Panel, style: StyleBox) -> void:
    field_panel.remove_stylebox_override("panel")
    field_panel.add_stylebox_override("panel", style)


func _input(event) -> void:
    if event is InputEventMouseMotion:
        for i in range(inventory.size.x):
            for j in range(inventory.size.y):
                var field_panel: Panel = _field_backgrounds[i][j]
                if _is_field_selected(Vector2(i, j)) && field_selected_style:
                    _set_field_panel_style(field_panel, field_selected_style)
                elif _is_field_highlighted(Vector2(i, j)) && field_highlighted_style:
                    _set_field_panel_style(field_panel, field_highlighted_style)
                else:
                    _set_field_panel_style(field_panel, field_style)


func _is_field_highlighted(field_coords: Vector2) -> bool:
    var grabbed_item: InventoryItem = get_grabbed_item()
    if grabbed_item:
        var global_grabbed_item_pos: Vector2 = _get_grabbed_item_global_pos()
        if _is_hovering(global_grabbed_item_pos):
            var grabbed_item_coords: Vector2 = get_field_coords(global_grabbed_item_pos)
            var item_size: Vector2 = inventory.get_item_size(grabbed_item)
            var rect: Rect2 = Rect2(grabbed_item_coords, item_size)
            return rect.has_point(field_coords)
        return false

    var item: InventoryItem = _get_item_on_field(field_coords)
    if item:
        return _is_item_highlighted(item)

    var mouse_pos: Vector2 = get_global_mouse_position()
    var rect: Rect2 = Rect2(_get_global_field_position(field_coords), field_dimensions)
    return rect.has_point(mouse_pos)


func _is_field_selected(field_coords: Vector2) -> bool:
    if !_selected_item:
        return false

    var item: InventoryItem = _get_item_on_field(field_coords)
    if !item:
        return false

    return item == _selected_item


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
