@tool
class_name CtrlInventoryGrid
extends Control

signal item_dropped(item, offset)
signal selection_changed
signal inventory_item_activated(item)
signal item_mouse_entered(item)
signal item_mouse_exited(item)

const GlootUndoRedo = preload("res://addons/gloot/editor/gloot_undo_redo.gd")
const CtrlInventoryItemRect = preload("res://addons/gloot/ui/ctrl_inventory_item_rect.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")
const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")

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
var _ctrl_item_container: WeakRef = weakref(null)
var _ctrl_drop_zone: CtrlDropZone
var _selected_item: InventoryItem = null


func _get_configuration_warnings() -> PackedStringArray:
    if inventory_path.is_empty():
        return PackedStringArray([
                "This node is not linked to an inventory, so it can't display any content.\n" + \
                "Set the inventory_path property to point to an InventoryGrid node."])
    return PackedStringArray()


func _ready() -> void:
    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        var ctrl_item_container = _ctrl_item_container.get_ref()
        if ctrl_item_container:
            ctrl_item_container.queue_free()

    var ctrl_item_container = Control.new()
    ctrl_item_container.size_flags_horizontal = SIZE_EXPAND_FILL
    ctrl_item_container.size_flags_vertical = SIZE_EXPAND_FILL
    ctrl_item_container.anchor_right = 1.0
    ctrl_item_container.anchor_bottom = 1.0
    add_child(ctrl_item_container)
    _ctrl_item_container = weakref(ctrl_item_container)

    _ctrl_drop_zone = CtrlDropZone.new()
    _ctrl_drop_zone.dragable_dropped.connect(_on_dragable_dropped)
    _ctrl_drop_zone.size = size
    resized.connect(func(): _ctrl_drop_zone.size = size)
    CtrlDragable.dragable_grabbed.connect(func(dragable: CtrlDragable, grab_position: Vector2):
        _ctrl_drop_zone.activate()
    )
    CtrlDragable.dragable_dropped.connect(func(dragable: CtrlDragable, zone: CtrlDropZone, drop_position: Vector2):
        _ctrl_drop_zone.deactivate()
    )
    _ctrl_drop_zone.mouse_entered.connect(_on_drop_zone_mouse_entered)
    _ctrl_drop_zone.mouse_exited.connect(_on_drop_zone_mouse_exited)
    add_child(_ctrl_drop_zone)
    _ctrl_drop_zone.deactivate()

    ctrl_item_container.resized.connect(func(): _ctrl_drop_zone.size = ctrl_item_container.size)

    if has_node(inventory_path):
        self.inventory = get_node_or_null(inventory_path)

    _refresh()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    if !inventory.contents_changed.is_connected(_refresh):
        inventory.contents_changed.connect(_refresh)
    if !inventory.item_modified.is_connected(_on_item_modified):
        inventory.item_modified.connect(_on_item_modified)
    if !inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.connect(_on_inventory_resized)
    if !inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.connect(_on_item_removed)


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.contents_changed.is_connected(_refresh):
        inventory.contents_changed.disconnect(_refresh)
    if inventory.item_modified.is_connected(_on_item_modified):
        inventory.item_modified.disconnect(_on_item_modified)
    if inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.disconnect(_on_inventory_resized)
    if inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.disconnect(_on_item_removed)


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


func _populate_list() -> void:
    var ctrl_item_container = _ctrl_item_container.get_ref()
    if inventory == null || ctrl_item_container == null:
        return
        
    for item in inventory.get_items():
        var ctrl_inventory_item = CtrlInventoryItemRect.new()
        ctrl_inventory_item.texture = default_item_texture
        ctrl_inventory_item.item = item
        ctrl_inventory_item.drag_z_index = drag_sprite_z_index
        ctrl_inventory_item.grabbed.connect(_on_item_grab.bind(ctrl_inventory_item))
        ctrl_inventory_item.dropped.connect(_on_item_drop.bind(ctrl_inventory_item))
        ctrl_inventory_item.activated.connect(_on_item_activated.bind(ctrl_inventory_item))
        ctrl_inventory_item.mouse_entered.connect(_on_item_mouse_entered.bind(ctrl_inventory_item))
        ctrl_inventory_item.mouse_exited.connect(_on_item_mouse_exited.bind(ctrl_inventory_item))
        ctrl_inventory_item.size = _get_item_sprite_size(item)

        ctrl_inventory_item.position = _get_field_position(inventory.get_item_position(item))
        if !stretch_item_sprites:
            # Position the item centered when it's not streched
            ctrl_inventory_item.position += _get_unstreched_sprite_offset(item)

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


func _on_item_grab(offset: Vector2, ctrl_inventory_item: CtrlInventoryItemRect) -> void:
    _select(null)


func _on_item_drop(zone: CtrlDropZone, drop_position: Vector2, ctrl_inventory_item: CtrlInventoryItemRect) -> void:
    var item = ctrl_inventory_item.item
    # The item might have been freed in case the item stack has been moved and merged with another
    # stack.
    if is_instance_valid(item) and inventory.has_item(item):
        _select(item)


func _get_item_sprite_size(item: InventoryItem) -> Vector2:
    if stretch_item_sprites:
        return _get_streched_item_sprite_size(item)
    else:
        return item.get_texture().get_size()


func _get_streched_item_sprite_size(item: InventoryItem) -> Vector2:
    var item_size := inventory.get_item_size(item)
    var sprite_size := Vector2(item_size) * field_dimensions

    # Also take item spacing into consideration
    sprite_size += (Vector2(item_size) - Vector2.ONE) * item_spacing

    return sprite_size


func _get_unstreched_sprite_offset(item: InventoryItem) -> Vector2:
    var texture = item.get_texture()
    if texture == null:
        texture = default_item_texture
    if texture == null:
        return Vector2.ZERO
    return (_get_streched_item_sprite_size(item) - texture.get_size()) / 2


func _on_item_activated(ctrl_inventory_item: CtrlInventoryItemRect) -> void:
    var item = ctrl_inventory_item.item
    if !item:
        return

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


func _on_drop_zone_mouse_entered() -> void:
    if CtrlDragable._grabbed_dragable == null:
        return
    var _grabbed_ctrl := (CtrlDragable._grabbed_dragable as CtrlInventoryItemRect)
    if _grabbed_ctrl == null || _grabbed_ctrl.item == null:
        return
    CtrlInventoryItemRect.override_preview_size(_get_item_sprite_size(_grabbed_ctrl.item))


func _on_drop_zone_mouse_exited() -> void:
    CtrlInventoryItemRect.restore_preview_size()


func _on_dragable_dropped(dragable: CtrlDragable, drop_position: Vector2) -> void:
    var item: InventoryItem = dragable.item
    if item == null:
        return

    if !inventory:
        return

    if inventory.has_item(item):
        _handle_item_move(item, drop_position)
    else:
        _handle_item_transfer(item, drop_position)


func _handle_item_move(item: InventoryItem, drop_position: Vector2) -> void:
    var field_coords = get_field_coords(drop_position + (field_dimensions / 2))
    if inventory.rect_free(Rect2i(field_coords, inventory.get_item_size(item)), item):
        _move_item(item, field_coords)
    elif inventory is InventoryGridStacked:
        _merge_item(item, field_coords)


func _handle_item_transfer(item: InventoryItem, drop_position: Vector2) -> void:
    var source_inventory: InventoryGrid = item.get_inventory()
    if source_inventory.item_protoset != inventory.item_protoset:
        return

    var field_coords = get_field_coords(drop_position + (field_dimensions / 2))
    source_inventory.transfer_to(item, inventory, field_coords)


func get_field_coords(local_pos: Vector2) -> Vector2i:
    # We have to consider the item spacing when calculating field coordinates, thus we expand the
    # size of each field by Vector2(item_spacing, item_spacing).
    var field_dimensions_ex = field_dimensions + Vector2(item_spacing, item_spacing)

    # We also don't want the item spacing to disturb snapping to the closest field, so we add half
    # the spacing to the local coordinates.
    var local_pos_ex = local_pos + (Vector2(item_spacing, item_spacing) / 2)

    var x: int = local_pos_ex.x / (field_dimensions_ex.x)
    var y: int = local_pos_ex.y / (field_dimensions_ex.y)
    return Vector2i(x, y)


func get_selected_inventory_item() -> InventoryItem:
    return _selected_item


func _move_item(item: InventoryItem, move_position: Vector2i) -> void:
    if Engine.is_editor_hint():
        GlootUndoRedo.move_inventory_item(inventory, item, move_position)
    else:
        inventory.move_item_to(item, move_position)

        
func _merge_item(item_src: InventoryItem, position: Vector2i) -> void:
    var item_dst = (inventory as InventoryGridStacked)._get_mergable_item_at(item_src, position)
    if item_dst == null:
        return

    if Engine.is_editor_hint():
        GlootUndoRedo.join_inventory_items(inventory, item_dst, item_src)
    else:
        (inventory as InventoryGridStacked).join(item_dst, item_src)


func _get_field_position(field_coords: Vector2i) -> Vector2:
    var field_position = Vector2(field_coords.x * field_dimensions.x, \
        field_coords.y * field_dimensions.y)
    field_position += Vector2(item_spacing * field_coords)
    return field_position


func _get_global_field_position(field_coords: Vector2i) -> Vector2:
    return _get_field_position(field_coords) + global_position


func deselect_inventory_item() -> void:
    _select(null)


func select_inventory_item(item: InventoryItem) -> void:
    _select(item)

