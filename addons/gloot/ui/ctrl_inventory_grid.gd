@tool
class_name CtrlInventoryGrid
extends Control

signal item_dropped(item, offset)
signal selection_changed
signal inventory_item_activated(item)
signal item_mouse_entered(item)
signal item_mouse_exited(item)

@export var field_dimensions: Vector2 = Vector2(32, 32) :
    get:
        return field_dimensions
    set(new_field_dimensions):
        field_dimensions = new_field_dimensions
        _refresh_grid_container()
@export var item_spacing: int = 0 :
    get:
        return item_spacing
    set(new_item_spacing):
        item_spacing = new_item_spacing
        _refresh()
@export var draw_grid: bool = true :
    get:
        return draw_grid
    set(new_draw_grid):
        draw_grid = new_draw_grid
        _refresh()
@export var grid_color: Color = Color.BLACK :
    get:
        return grid_color
    set(new_grid_color):
        grid_color = new_grid_color
        _refresh()
@export var draw_selections: bool = false :
    get:
        return draw_selections
    set(new_draw_selections):
        draw_selections = new_draw_selections
@export var selection_color: Color = Color.GRAY
@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        var node: Node = get_node_or_null(inventory_path)

        if node == null:
            return

        if is_inside_tree():
            assert(node is InventoryGrid)
            
        self.inventory = node
        update_configuration_warnings()
@export var default_item_texture: Texture2D :
    get:
        return default_item_texture
    set(new_default_item_texture):
        default_item_texture = new_default_item_texture
        _refresh()
@export var stretch_item_sprites: bool = true :
    get:
        return stretch_item_sprites
    set(new_stretch_item_sprites):
        stretch_item_sprites = new_stretch_item_sprites
        _refresh()
@export var drag_sprite_z_index: int = 1
var inventory: InventoryGrid = null :
    get:
        return inventory
    set(new_inventory):
        if inventory == new_inventory:
            return

        _select(null)

        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()

        _refresh()
var _gloot_undo_redo = null
var _grabbed_ctrl_inventory_item = null
var _grab_offset: Vector2
var _ctrl_inventory_item_script = preload("ctrl_inventory_item_rect.gd")
var _drag_sprite: WeakRef = weakref(null)
var _ctrl_item_container: WeakRef = weakref(null)
var _selected_item: InventoryItem = null
var _gloot: Node = null


func _get_configuration_warnings() -> PackedStringArray:
    if inventory_path.is_empty():
        return PackedStringArray([
                "This node is not linked to an inventory, so it can't display any content.\n" + \
                "Set the inventory_path property to point to an InventoryGrid node."])
    return PackedStringArray()


func _ready() -> void:
    _gloot = _get_gloot()

    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        var ctrl_item_container = _ctrl_item_container.get_ref()
        if ctrl_item_container:
            ctrl_item_container.queue_free()
        if _drag_sprite.get_ref():
            _drag_sprite.get_ref().queue_free()

    var ctrl_item_container = Control.new()
    ctrl_item_container.size_flags_horizontal = SIZE_EXPAND_FILL
    ctrl_item_container.size_flags_vertical = SIZE_EXPAND_FILL
    ctrl_item_container.anchor_right = 1.0
    ctrl_item_container.anchor_bottom = 1.0
    add_child(ctrl_item_container)
    _ctrl_item_container = weakref(ctrl_item_container)

    var drag_sprite = Sprite2D.new()
    drag_sprite.centered = false
    drag_sprite.z_index = drag_sprite_z_index
    drag_sprite.hide()
    add_child(drag_sprite)
    _drag_sprite = weakref(drag_sprite)

    if has_node(inventory_path):
        self.inventory = get_node_or_null(inventory_path)

    _refresh()
    if !Engine.is_editor_hint() && _gloot:
        _gloot.item_dropped.connect(Callable(self, "_on_item_dropped"))


func _get_gloot() -> Node:
    # This is a "temporary" hack until a better solution is found!
    # This is a tool script that is also executed inside the editor, where the "GLoot" singleton is
    # not visible - leading to errors inside the editor.
    # To work around that, we obtain the singleton by name.
    return get_tree().root.get_node_or_null("GLoot")


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    if !inventory.contents_changed.is_connected(Callable(self, "_refresh")):
        inventory.contents_changed.connect(Callable(self, "_refresh"))
    if !inventory.item_modified.is_connected(Callable(self, "_on_item_modified")):
        inventory.item_modified.connect(Callable(self, "_on_item_modified"))
    if !inventory.size_changed.is_connected(Callable(self, "_on_inventory_resized")):
        inventory.size_changed.connect(Callable(self, "_on_inventory_resized"))
    if !inventory.item_removed.is_connected(Callable(self, "_on_item_removed")):
        inventory.item_removed.connect(Callable(self, "_on_item_removed"))


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.contents_changed.is_connected(Callable(self, "_refresh")):
        inventory.contents_changed.disconnect(Callable(self, "_refresh"))
    if inventory.item_modified.is_connected(Callable(self, "_on_item_modified")):
        inventory.item_modified.disconnect(Callable(self, "_on_item_modified"))
    if inventory.size_changed.is_connected(Callable(self, "_on_inventory_resized")):
        inventory.size_changed.disconnect(Callable(self, "_on_inventory_resized"))
    if inventory.item_removed.is_connected(Callable(self, "_on_item_removed")):
        inventory.item_removed.disconnect(Callable(self, "_on_item_removed"))


func _on_item_modified(_item: InventoryItem) -> void:
    _refresh()


func _on_inventory_resized() -> void:
    _refresh()


func _on_item_removed(_item: InventoryItem) -> void:
    if _item == _selected_item:
        _select(null)


func _refresh() -> void:
    _refresh_grid_container()
    _clear_list()
    _populate_list()
    queue_redraw()


func _process(_delta) -> void:
    var drag_sprite = _drag_sprite.get_ref()
    if drag_sprite && drag_sprite.visible:
        drag_sprite.global_position = get_global_mouse_position() - _grab_offset


func _draw() -> void:
    if !inventory:
        return
    if draw_grid:
        _draw_grid(Vector2.ZERO, inventory.size.x, inventory.size.y, field_dimensions, item_spacing)


func _draw_grid(pos: Vector2, w: int, h: int, fsize: Vector2, spacing: int) -> void:
    if w <= 0 || h <= 0 || spacing < 0:
        return

    if spacing <= 1:
        var rect = Rect2(pos, _get_inventory_size_px())
        draw_rect(rect, grid_color, false)
        for i in range(w):
            var from: Vector2 = Vector2(i * fsize.x, 0) + pos
            var to: Vector2 = Vector2(i * fsize.x, rect.size.y) + pos
            from += Vector2(spacing, 0)
            to += Vector2(spacing, 0)
            draw_line(from, to, grid_color)
        for j in range(h):
            var from: Vector2 = Vector2(0, j * fsize.y) + pos
            var to: Vector2 = Vector2(rect.size.x, j * fsize.y) + pos
            from += Vector2(0, spacing)
            to += Vector2(0, spacing)
            draw_line(from, to, grid_color)
    else:
        for i in range(w):
            for j in range(h):
                var field_pos = pos + Vector2(i * fsize.x, j * fsize.y) + Vector2(i, j) * spacing
                var field_rect = Rect2(field_pos, fsize)
                draw_rect(field_rect, grid_color, false)


func _get_inventory_size_px() -> Vector2:
    var result := Vector2(inventory.size.x * field_dimensions.x, \
        inventory.size.y * field_dimensions.y)

    # Also take item spacing into consideration
    result += Vector2(inventory.size - Vector2i.ONE) * item_spacing

    return result


func _refresh_grid_container() -> void:
    if !inventory:
        return

    custom_minimum_size = _get_inventory_size_px()
    size = custom_minimum_size


func _clear_list() -> void:
    var ctrl_item_container = _ctrl_item_container.get_ref()
    if !ctrl_item_container:
        return

    for ctrl_inventory_item in ctrl_item_container.get_children():
        ctrl_item_container.remove_child(ctrl_inventory_item)
        ctrl_inventory_item.queue_free()

    _grabbed_ctrl_inventory_item = null


func _populate_list() -> void:
    var ctrl_item_container = _ctrl_item_container.get_ref()
    if inventory == null || ctrl_item_container == null:
        return
        
    for item in inventory.get_items():
        var ctrl_inventory_item = _ctrl_inventory_item_script.new()
        ctrl_inventory_item.ctrl_inventory = self
        ctrl_inventory_item.texture = default_item_texture
        ctrl_inventory_item.item = item
        ctrl_inventory_item.grabbed.connect(Callable(self, "_on_item_grab"))
        ctrl_inventory_item.activated.connect(Callable(self, "_on_item_activated"))
        ctrl_inventory_item.mouse_entered.connect(Callable(self, "_on_item_mouse_entered").bind(ctrl_inventory_item))
        ctrl_inventory_item.mouse_exited.connect(Callable(self, "_on_item_mouse_exited").bind(ctrl_inventory_item))
        ctrl_item_container.add_child(ctrl_inventory_item)

    _refresh_selection()


func _refresh_selection() -> void:
    if !draw_selections:
        return

    if !_ctrl_item_container.get_ref():
        return

    for ctrl_item in _ctrl_item_container.get_ref().get_children():
        ctrl_item.selected = ctrl_item.item && (ctrl_item.item == _selected_item)
        ctrl_item.selection_bg_color = selection_color


func _on_item_grab(ctrl_inventory_item, offset: Vector2) -> void:
    _select(null)
    _grabbed_ctrl_inventory_item = ctrl_inventory_item
    _grabbed_ctrl_inventory_item.hide()
    _grab_offset = offset
    if _gloot:
        _gloot._grabbed_inventory_item = get_grabbed_item()
        _gloot._grab_offset = _grab_offset
    var drag_sprite = _drag_sprite.get_ref()
    if drag_sprite:
        drag_sprite.texture = ctrl_inventory_item.texture
        if drag_sprite.texture == null:
            drag_sprite.texture = default_item_texture
        if stretch_item_sprites:
            var texture_size: Vector2 = drag_sprite.texture.get_size()
            var streched_size: Vector2 = _get_streched_item_sprite_size(ctrl_inventory_item.item)
            drag_sprite.scale = streched_size / texture_size
        drag_sprite.show()


func _get_streched_item_sprite_size(item: InventoryItem) -> Vector2:
    var item_size := inventory.get_item_size(item)
    var sprite_size := Vector2(item_size) * field_dimensions

    # Also take item spacing into consideration
    sprite_size += (Vector2(item_size) - Vector2.ONE) * item_spacing

    return sprite_size


func _on_item_activated(ctrl_inventory_item) -> void:
    var item = ctrl_inventory_item.item
    if !item:
        return

    _grabbed_ctrl_inventory_item = null
    if _drag_sprite.get_ref():
        _drag_sprite.get_ref().hide()

    inventory_item_activated.emit(item)


func _on_item_mouse_entered(ctrl_inventory_item) -> void:
    item_mouse_entered.emit(ctrl_inventory_item.item)


func _on_item_mouse_exited(ctrl_inventory_item) -> void:
    item_mouse_exited.emit(ctrl_inventory_item.item)


func _select(item: InventoryItem) -> void:
    if item == _selected_item:
        return

    _selected_item = item
    _refresh_selection()
    selection_changed.emit()


# Using _input instead of _gui_input because _gui_input is only called for "mouse released"
# (InputEventMouseButton.pressed==false) events if the same control previously triggered the "mouse
# pressed" event (InputEventMouseButton.pressed==true).
# This makes dragging items from one CtrlInventoryGrid to another impossible to implement with
# _gui_input.
func _input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton):
        return

    if !_grabbed_ctrl_inventory_item:
        return

    var mb_event: InputEventMouseButton = event
    if mb_event.is_pressed() || mb_event.button_index != MOUSE_BUTTON_LEFT:
        return

    _handle_item_release(_grabbed_ctrl_inventory_item.item)


func _handle_item_release(item: InventoryItem) -> void:
    _grabbed_ctrl_inventory_item.show()

    if _gloot:
        _gloot._grabbed_inventory_item = null

    var global_grabbed_item_pos := _get_grabbed_item_global_pos()
    if _is_hovering(global_grabbed_item_pos):
        _handle_item_move(item, global_grabbed_item_pos)
    else:
        _handle_item_drop(item, global_grabbed_item_pos)

    # The item might have been freed in case the item stack has been moved and merged with another
    # stack.
    if is_instance_valid(item) and inventory.has_item(item):
        _select(item)

    _grabbed_ctrl_inventory_item = null
    if _drag_sprite.get_ref():
        _drag_sprite.get_ref().hide()


func _handle_item_move(item: InventoryItem, global_grabbed_item_pos: Vector2) -> void:
    var field_coords = get_field_coords(global_grabbed_item_pos)
    if inventory.rect_free(Rect2i(field_coords, inventory.get_item_size(item)), item):
        _move_item(item, field_coords)
    elif inventory is InventoryGridStacked:
        _merge_item(item, field_coords)


func _handle_item_drop(item: InventoryItem, global_grabbed_item_pos: Vector2) -> void:
    # Using WeakRefs for the item_dropped signals, as items might be freed at some point of dropping
    # (when merging with other items)
    var wr_item := weakref(item)
    item_dropped.emit(wr_item, global_grabbed_item_pos)
    if !Engine.is_editor_hint() && _gloot:
        _gloot.item_dropped.emit(wr_item, global_grabbed_item_pos)


func _get_grabbed_item_global_pos() -> Vector2:
    return get_global_mouse_position() - _grab_offset + (field_dimensions / 2)


func _on_item_dropped(wr_item: WeakRef, global_drop_pos: Vector2) -> void:
    var item: InventoryItem = wr_item.get_ref()
    if item == null:
        return

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


func get_field_coords(global_pos: Vector2) -> Vector2i:
    var local_pos = global_pos - get_global_rect().position

    # We have to consider the item spacing when calculating field coordinates, thus we expand the
    # size of each field by Vector2(item_spacing, item_spacing).
    var field_dimensions_ex = field_dimensions + Vector2(item_spacing, item_spacing)

    # We also don't want the item spacing to disturb snapping to the closest field, so we add half
    # the spacing to the local coordinates.
    var local_pos_ex = local_pos + Vector2(item_spacing, item_spacing) / 2

    var x: int = local_pos_ex.x / (field_dimensions_ex.x)
    var y: int = local_pos_ex.y / (field_dimensions_ex.y)
    return Vector2i(x, y)


func get_selected_inventory_item() -> InventoryItem:
    return _selected_item


# TODO: Find a better way for undoing/redoing item movements
func _move_item(item: InventoryItem, position: Vector2i) -> void:
    if _gloot_undo_redo:
        _gloot_undo_redo.move_inventory_item(inventory, item, position)
    else:
        inventory.move_item_to(item, position)

        
# TODO: Find a better way for undoing/redoing item merges
func _merge_item(item_src: InventoryItem, position: Vector2i) -> void:
    var item_dst = (inventory as InventoryGridStacked)._get_mergable_item_at(item_src, position)
    if item_dst == null:
        return

    if _gloot_undo_redo:
        _gloot_undo_redo.join_inventory_items(inventory, item_dst, item_src)
    else:
        (inventory as InventoryGridStacked).join(item_dst, item_src)


func _get_field_position(field_coords: Vector2i) -> Vector2:
    var field_position = Vector2(field_coords.x * field_dimensions.x, \
        field_coords.y * field_dimensions.y)
    field_position += Vector2(item_spacing * field_coords)
    return field_position


func _get_global_field_position(field_coords: Vector2i) -> Vector2:
    return _get_field_position(field_coords) + global_position


func get_grabbed_item() -> InventoryItem:
    if _grabbed_ctrl_inventory_item:
        return _grabbed_ctrl_inventory_item.item

    return null


func deselect_inventory_item() -> void:
    _select(null)


func select_inventory_item(item: InventoryItem) -> void:
    _select(item)

