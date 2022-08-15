class_name CtrlInventoryGrid
extends Control
tool

signal item_dropped
signal inventory_item_activated

export(Vector2) var field_dimensions: Vector2 = Vector2(32, 32) setget _set_field_dimensions
export(Color) var grid_color: Color = Color.black
export(Color) var selection_color: Color = Color.gray
export(NodePath) var inventory_path: NodePath setget _set_inventory_path
export(Texture) var default_item_texture: Texture
export(int) var drag_sprite_z_index: int = 1
export(bool) var selections_enabled: bool = false setget _set_selections_enabled
var inventory: InventoryGrid = null setget _set_inventory
var _gloot_undo_redo = null
var _grabbed_ctrl_inventory_item = null
var _grab_offset: Vector2
var _ctrl_inventory_item_script = preload("ctrl_inventory_item_rect.gd")
var _drag_sprite: Sprite
var _ctrl_item_container: Control
var _selected_item: InventoryItem = null


func _set_field_dimensions(new_field_dimensions) -> void:
    field_dimensions = new_field_dimensions
    _refresh_grid_container()


func _get_configuration_warning() -> String:
    if inventory_path.is_empty():
        return "This node is not linked to an inventory, so it can't display any content.\n" + \
               "Set the inventory_path property to point to an InventoryGrid node."
    return ""


func _set_inventory_path(new_inv_path: NodePath) -> void:
    inventory_path = new_inv_path
    var node: Node = get_node_or_null(inventory_path)

    if is_inside_tree() && node:
        assert(node is InventoryGrid)
        
    _set_inventory(node)
    update_configuration_warning()


func _set_selections_enabled(new_selections_enabled: bool) -> void:
    selections_enabled = new_selections_enabled
    if !selections_enabled:
        _select(null)


func _set_inventory(new_inventory: InventoryGrid) -> void:
    if inventory == new_inventory:
        return

    _disconnect_inventory_signals()
    inventory = new_inventory
    _connect_inventory_signals()

    _refresh()


func _ready() -> void:
    if Engine.editor_hint:
        # Clean up, in case it is duplicated in the editor
        for child in get_children():
            child.queue_free()

    _ctrl_item_container = Control.new()
    _ctrl_item_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _ctrl_item_container.size_flags_vertical = SIZE_EXPAND_FILL
    _ctrl_item_container.anchor_right = 1.0
    _ctrl_item_container.anchor_bottom = 1.0
    add_child(_ctrl_item_container)

    _drag_sprite = Sprite.new()
    _drag_sprite.centered = false
    _drag_sprite.z_index = drag_sprite_z_index
    _drag_sprite.hide()
    add_child(_drag_sprite)
    if has_node(inventory_path):
        _set_inventory(get_node_or_null(inventory_path))

    _refresh()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    if !inventory.is_connected("contents_changed", self, "_refresh"):
        inventory.connect("contents_changed", self, "_refresh")
    if !inventory.is_connected("item_modified", self, "_on_item_modified"):
        inventory.connect("item_modified", self, "_on_item_modified")


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.is_connected("contents_changed", self, "_refresh"):
        inventory.disconnect("contents_changed", self, "_refresh")
    if inventory.is_connected("item_modified", self, "_on_item_modified"):
        inventory.disconnect("item_modified", self, "_on_item_modified")


func _on_item_modified(_item: InventoryItem) -> void:
    _refresh()


func _refresh() -> void:
    _refresh_grid_container()
    _clear_list()
    _populate_list()


func _process(_delta) -> void:
    if _drag_sprite && _drag_sprite.visible:
        _drag_sprite.global_position = get_global_mouse_position() - _grab_offset
    update()


func _draw() -> void:
    if !inventory:
        return
    _draw_grid(Vector2.ZERO, inventory.size.x, inventory.size.y, field_dimensions)


func _draw_grid(pos: Vector2, w: int, h: int, fsize: Vector2) -> void:
    var rect = Rect2(pos, Vector2(w * fsize.x, h * fsize.y))
    draw_rect(rect, grid_color, false)
    for i in range(w):
        var from: Vector2 = Vector2(i * fsize.x, 0) + pos
        var to: Vector2 = Vector2(i * fsize.x, h * fsize.y) + pos
        draw_line(from, to, grid_color)
    for j in range(h):
        var from: Vector2 = Vector2(0, j * fsize.y) + pos
        var to: Vector2 = Vector2(w * fsize.x, j * fsize.y) + pos
        draw_line(from, to, grid_color)


func _refresh_grid_container() -> void:
    if !inventory:
        return

    rect_min_size = Vector2(inventory.size.x * field_dimensions.x, \
        inventory.size.y * field_dimensions.y)
    rect_size = rect_min_size


func _clear_list() -> void:
    if !_ctrl_item_container:
        return

    for ctrl_inventory_item in _ctrl_item_container.get_children():
        _ctrl_item_container.remove_child(ctrl_inventory_item)
        ctrl_inventory_item.queue_free()

    _grabbed_ctrl_inventory_item = null


func _populate_list() -> void:
    if inventory == null || _ctrl_item_container == null:
        return
        
    for item in inventory.get_items():
        var ctrl_inventory_item = _ctrl_inventory_item_script.new()
        ctrl_inventory_item.ctrl_inventory = self
        ctrl_inventory_item.texture = default_item_texture
        ctrl_inventory_item.item = item
        ctrl_inventory_item.connect("grabbed", self, "_on_item_grab")
        ctrl_inventory_item.connect("activated", self, "_on_item_activated")
        _ctrl_item_container.add_child(ctrl_inventory_item)

    _refresh_selection()


func _refresh_selection() -> void:
    if !_ctrl_item_container:
        return

    for ctrl_item in _ctrl_item_container.get_children():
        ctrl_item.selected = ctrl_item.item && (ctrl_item.item == _selected_item)
        ctrl_item.selection_bg_color = selection_color


func _on_item_grab(ctrl_inventory_item, offset: Vector2) -> void:
    _select(null)
    _grabbed_ctrl_inventory_item = ctrl_inventory_item
    _grabbed_ctrl_inventory_item.hide()
    _grab_offset = offset
    if _drag_sprite:
        _drag_sprite.texture = ctrl_inventory_item.texture
        if _drag_sprite.texture == null:
            _drag_sprite.texture = default_item_texture
        var item_size = inventory.get_item_size(ctrl_inventory_item.item)
        var texture_size = _drag_sprite.texture.get_size()
        _drag_sprite.scale = item_size * field_dimensions / texture_size
        _drag_sprite.show()


func _on_item_activated(ctrl_inventory_item) -> void:
    var item: InventoryItem = ctrl_inventory_item.item
    if !item:
        return

    _grabbed_ctrl_inventory_item = null
    if _drag_sprite:
        _drag_sprite.hide()

    emit_signal("inventory_item_activated", item)


func _select(item: InventoryItem) -> void:
    if selections_enabled:
        _selected_item = item
        _refresh_selection()


func _input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton):
        return

    if !_grabbed_ctrl_inventory_item:
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.is_pressed() || mb_event.button_index != BUTTON_LEFT:
        return

    var item: InventoryItem = _grabbed_ctrl_inventory_item.item
    _grabbed_ctrl_inventory_item.show()

    var global_grabbed_item_pos = get_global_mouse_position() - _grab_offset + (field_dimensions / 2)
    if _is_mouse_hovering():
        var field_coords = get_field_coords(global_grabbed_item_pos)
        _move_item(inventory.get_item_index(item), field_coords)
    else:
        emit_signal("item_dropped", item, global_grabbed_item_pos)
    _select(item)
    _grabbed_ctrl_inventory_item = null
    if _drag_sprite:
        _drag_sprite.hide()


func _is_mouse_hovering() -> bool:
    return get_global_rect().has_point(get_global_mouse_position())


func get_field_coords(global_pos: Vector2) -> Vector2:
    var offset = global_pos - get_global_rect().position
    var x: int = offset.x / field_dimensions.x
    var y: int = offset.y / field_dimensions.y
    return Vector2(x, y)


func get_selected_inventory_items() -> Array:
    if _selected_item:
        return [_selected_item]
    else:
        return []


# TODO: Find a better way for undoing/redoing item movements
func _move_item(item_index: int, position: Vector2) -> void:
    var item = inventory.get_items()[item_index]
    if _gloot_undo_redo:
        _gloot_undo_redo.move_inventory_item(inventory, item, position)
    else:
        inventory.move_item_to(item, position)
