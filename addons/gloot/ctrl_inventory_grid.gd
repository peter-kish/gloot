class_name CtrlInventoryGrid
extends Control
tool

signal item_dropped
signal inventory_item_activated

export(Vector2) var field_dimensions: Vector2 = Vector2(32, 32) setget _set_field_dimensions
export(int) var item_spacing: int = 0 setget _set_item_spacing
export(bool) var enable_grid: bool = true
export(Color) var grid_color: Color = Color.black
export(bool) var enable_selections: bool = false setget _set_enable_selections
export(Color) var selection_color: Color = Color.gray
export(NodePath) var inventory_path: NodePath setget _set_inventory_path
export(Texture) var default_item_texture: Texture
export(int) var drag_sprite_z_index: int = 1
var inventory: InventoryGrid = null setget _set_inventory
var _gloot_undo_redo = null
var _grabbed_ctrl_inventory_item = null
var _grab_offset: Vector2
var _ctrl_inventory_item_script = preload("ctrl_inventory_item_rect.gd")
var _drag_sprite: Sprite
var _ctrl_item_container: Control
var _selected_item: InventoryItem = null
var _gloot: Node = null


func _set_field_dimensions(new_field_dimensions: Vector2) -> void:
    field_dimensions = new_field_dimensions
    _refresh_grid_container()


func _set_item_spacing(new_item_spacing: int) -> void:
    item_spacing = new_item_spacing
    _refresh()


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


func _set_enable_selections(new_enable_selections: bool) -> void:
    enable_selections = new_enable_selections
    if !enable_selections:
        _select(null)


func _set_inventory(new_inventory: InventoryGrid) -> void:
    if inventory == new_inventory:
        return

    _disconnect_inventory_signals()
    inventory = new_inventory
    _connect_inventory_signals()

    _refresh()


func _ready() -> void:
    _gloot = _get_gloot()

    if Engine.editor_hint:
        # Clean up, in case it is duplicated in the editor
        if _ctrl_item_container:
            _ctrl_item_container.queue_free()
        if _drag_sprite:
            _drag_sprite.queue_free()

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
    if !Engine.editor_hint && _gloot:
        _gloot.connect("item_dropped", self, "_on_item_dropped")


func _get_gloot() -> Node:
    # This is a "temporary" hack until a better solution is found!
    # This is a tool script that is also executed inside the editor, where the "GLoot" singleton is
    # not visible - leading to errors inside the editor.
    # To work around that, we obtain the sigleton by name.
    return get_tree().root.get_node_or_null("GLoot")


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
    if enable_grid:
        _draw_grid(Vector2.ZERO, inventory.size.x, inventory.size.y, field_dimensions, item_spacing)


func _draw_grid(pos: Vector2, w: int, h: int, fsize: Vector2, spacing: int) -> void:
    if w <= 0 || h <= 0 || spacing < 0:
        return

    if spacing == 0:
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
    else:
        for i in range(w):
            for j in range(h):
                var field_pos = pos + Vector2(i * fsize.x, j * fsize.y) + Vector2(i, j) * spacing
                var field_rect = Rect2(field_pos, fsize)
                draw_rect(field_rect, grid_color, false)


func _refresh_grid_container() -> void:
    if !inventory:
        return

    rect_min_size = Vector2(inventory.size.x * field_dimensions.x, \
        inventory.size.y * field_dimensions.y)
    rect_min_size += (inventory.size - Vector2.ONE) * item_spacing
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
        var texture_size = _drag_sprite.texture.get_size()
        var sprite_size = _get_item_sprite_size(ctrl_inventory_item.item)
        _drag_sprite.scale = sprite_size / texture_size
        _drag_sprite.show()


func _get_item_sprite_size(item: InventoryItem) -> Vector2:
    var item_size = inventory.get_item_size(item)
    var sprite_size = (item_size * field_dimensions) + ((item_size - Vector2.ONE) * item_spacing)
    return sprite_size


func _on_item_activated(ctrl_inventory_item) -> void:
    var item: InventoryItem = ctrl_inventory_item.item
    if !item:
        return

    _grabbed_ctrl_inventory_item = null
    if _drag_sprite:
        _drag_sprite.hide()

    emit_signal("inventory_item_activated", item)


func _select(item: InventoryItem) -> void:
    if enable_selections:
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
    if _is_hovering(global_grabbed_item_pos):
        var field_coords = get_field_coords(global_grabbed_item_pos)
        _move_item(inventory.get_item_index(item), field_coords)
    else:
        emit_signal("item_dropped", item, global_grabbed_item_pos)
        if !Engine.editor_hint && _gloot:
            _gloot.emit_signal("item_dropped", item, global_grabbed_item_pos)
    _select(item)
    _grabbed_ctrl_inventory_item = null
    if _drag_sprite:
        _drag_sprite.hide()


func _on_item_dropped(item: InventoryItem, global_drop_pos: Vector2) -> void:
    if !_is_hovering(global_drop_pos):
        return

    if !inventory:
        return

    var source_inventory: InventoryGrid = item.get_inventory()
    if source_inventory.item_protoset != inventory.item_protoset:
        return

    var field_coords = get_field_coords(global_drop_pos)
    source_inventory.transfer_to(item, inventory, field_coords)


func _is_hovering(global_pos: Vector2) -> bool:
    return get_global_rect().has_point(global_pos)


func get_field_coords(global_pos: Vector2) -> Vector2:
    var local_pos = global_pos - get_global_rect().position
    local_pos += Vector2(item_spacing, item_spacing) / 2
    var x: int = local_pos.x / (field_dimensions.x + item_spacing)
    var y: int = local_pos.y / (field_dimensions.y + item_spacing)
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
