class_name CtrlInventoryGridEx
extends CtrlInventoryGrid
tool

const Verify = preload("res://addons/gloot/verify.gd")

export(StyleBox) var field_style: StyleBox setget _set_field_style
export(StyleBox) var field_highlighted_style: StyleBox setget _set_field_highlighted_style
export(StyleBox) var field_selected_style: StyleBox setget _set_field_selected_style
export(StyleBox) var selection_style: StyleBox setget _set_selection_style
var _field_background_grid: Control
var _field_backgrounds: Array
var _selection_panel: Panel
var _prev_hovered_field_coords: Vector2
var _pending_highlight = null
var _pending_highlight_reset = null


func _set_field_style(new_field_style: StyleBox) -> void:
    field_style = new_field_style
    _refresh()


func _set_field_highlighted_style(new_field_highlighted_style: StyleBox) -> void:
    field_highlighted_style = new_field_highlighted_style
    _refresh()


func _set_field_selected_style(new_field_selected_style: StyleBox) -> void:
    field_selected_style = new_field_selected_style
    _refresh()


func _set_selection_style(new_selection_style: StyleBox) -> void:
    selection_style = new_selection_style
    _refresh()


func _refresh() -> void:
    ._refresh()
    _refresh_field_background_grid()


func _refresh_selection() -> void:
    ._refresh_selection()
    if !_selection_panel:
        _create_selection_panel()
    _selection_panel.visible = (_selected_item != null) && (selection_style != null)
    if _selected_item:
        move_child(_selection_panel, get_child_count() - 1)

        var selection_pos = _get_field_position(inventory.get_item_position(_selected_item))
        var selection_size = _get_streched_item_sprite_size(_selected_item)
        _selection_panel.rect_position = selection_pos
        _selection_panel.rect_size = selection_size


func _refresh_field_background_grid() -> void:
    if _field_background_grid:
        remove_child(_field_background_grid)
        _field_background_grid.queue_free()
        _field_background_grid = null
        _field_backgrounds = []

    if !_selection_panel:
        _create_selection_panel()
    _set_panel_style(_selection_panel, selection_style)
    _selection_panel.visible = (_selected_item != null) && (selection_style != null)

    if !inventory:
        return

    _field_background_grid = Control.new()
    add_child(_field_background_grid)
    move_child(_field_background_grid, 0)

    for i in range(inventory.size.x):
        _field_backgrounds.append([])
        for j in range(inventory.size.y):
            var field_panel: Panel = Panel.new()
            _set_panel_style(field_panel, field_style)
            field_panel.visible = (field_style != null)
            field_panel.rect_size = field_dimensions
            field_panel.rect_position = _get_field_position(Vector2(i, j))
            _field_background_grid.add_child(field_panel)
            _field_backgrounds[i].append(field_panel)


func _create_selection_panel() -> void:
    _selection_panel = Panel.new()
    add_child(_selection_panel);
    move_child(_selection_panel, get_child_count() - 1)


func _set_panel_style(panel: Panel, style: StyleBox) -> void:
    panel.remove_stylebox_override("panel")
    panel.add_stylebox_override("panel", style)


func _ready() -> void:
    connect("item_selected", self, "_on_item_selected")
    connect("item_deselected", self, "_on_item_deselected")


func _on_item_selected(item: InventoryItem) -> void:
    if !inventory:
        return

    var item_size := inventory.get_item_size(item)
    var item_pos := inventory.get_item_position(item)
    _pending_highlight = Rect2(item_pos, item_size)


func _on_item_deselected(item: InventoryItem) -> void:
    if !inventory:
        return

    var item_size := inventory.get_item_size(item)
    var item_pos := inventory.get_item_position(item)
    _pending_highlight_reset = Rect2(item_pos, item_size)


func _input(event) -> void:
    if !(event is InputEventMouseMotion):
        return
    
    var hovered_field_coords := Vector2(-1, -1)
    if _is_hovering(get_global_mouse_position()):
        hovered_field_coords = get_field_coords(get_global_mouse_position())

    if _prev_hovered_field_coords != hovered_field_coords:
        _reset_highlights()
        _highlight_hovered_fields(hovered_field_coords)
        
    _prev_hovered_field_coords = hovered_field_coords


func _reset_highlights() -> void:
    _highlight_fields(_prev_hovered_field_coords, field_style)

    if _pending_highlight_reset:
        _highlight_rect(_pending_highlight_reset, field_style)
        _pending_highlight_reset = null


func _highlight_hovered_fields(hovered_field_coords: Vector2) -> void:
    _highlight_fields(hovered_field_coords, field_highlighted_style)
    
    if _pending_highlight:
        _highlight_rect(_pending_highlight, field_highlighted_style)
        _pending_highlight = null


func _highlight_fields(field_coords: Vector2, style: StyleBox) -> void:
    if !style || !Verify.vector_positive(field_coords):
        return

    var item := inventory.get_item_at(field_coords)
    if item:
        var item_size := inventory.get_item_size(item)
        if item_size.x > 1 && item_size.y > 1:
            _highlight_item(item, style)
            return

    _set_panel_style(_field_backgrounds[field_coords.x][field_coords.y], style)


func _highlight_item(item: InventoryItem, style: StyleBox) -> void:
    if !item || !style:
        return

    var item_size := inventory.get_item_size(item)
    var item_pos := inventory.get_item_position(item)
    _highlight_rect(Rect2(item_pos, item_size), style)


func _highlight_rect(rect: Rect2, style: StyleBox) -> void:
    for i in range(rect.position.x, rect.size.x + rect.position.x):
        for j in range(rect.position.y, rect.size.y + rect.position.y):
            _set_panel_style(_field_backgrounds[i][j], style)


func _is_field_highlighted(field_coords: Vector2) -> bool:
    var grabbed_item: InventoryItem = _get_global_grabbed_item()
    if grabbed_item:
        var global_grabbed_item_pos: Vector2 = _get_global_grabbed_item_global_pos()
        if _is_hovering(global_grabbed_item_pos):
            var grabbed_item_coords: Vector2 = get_field_coords(global_grabbed_item_pos)
            var item_size: Vector2 = inventory.get_item_size(grabbed_item)
            var rect: Rect2 = Rect2(grabbed_item_coords, item_size)
            return rect.has_point(field_coords)
        return false

    var item: InventoryItem = inventory.get_item_at(field_coords)
    if item:
        return _is_item_highlighted(item)

    var mouse_pos: Vector2 = get_global_mouse_position()
    var rect: Rect2 = Rect2(_get_global_field_position(field_coords), field_dimensions)
    return rect.has_point(mouse_pos)


func _get_global_grabbed_item() -> InventoryItem:
    var grabbed_item: InventoryItem = get_grabbed_item()
    if !grabbed_item && _gloot:
        grabbed_item = _gloot._grabbed_inventory_item
    return grabbed_item


func _get_global_grabbed_item_global_pos() -> Vector2:
    if _gloot && _gloot._grabbed_inventory_item:
        return get_global_mouse_position() - _gloot._grab_offset + (field_dimensions / 2)
    return Vector2(-1, -1)
    

func _is_field_selected(field_coords: Vector2) -> bool:
    if !_selected_item:
        return false

    var item: InventoryItem = inventory.get_item_at(field_coords)
    if !item:
        return false

    return item == _selected_item


func _is_item_highlighted(item: InventoryItem) -> bool:
    var item_coords: Vector2 = inventory.get_item_position(item)
    var item_size: Vector2 = inventory.get_item_size(item)
    var item_global_pos: Vector2 = _get_global_field_position(item_coords)
    var item_global_size: Vector2 = _get_streched_item_sprite_size(item)
    if !stretch_item_sprites:
        item_global_size = Vector2(field_dimensions.x * item_size.x, \
            field_dimensions.y * item_size.y)

    return Rect2(item_global_pos, item_global_size).has_point(get_global_mouse_position())
