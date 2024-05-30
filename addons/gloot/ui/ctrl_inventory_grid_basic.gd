@tool
extends Control

signal item_dropped(item, offset)
signal selection_changed
signal inventory_item_activated(item)
signal inventory_item_context_activated(item)
signal item_mouse_entered(item)
signal item_mouse_exited(item)

const GlootUndoRedo = preload("res://addons/gloot/editor/gloot_undo_redo.gd")
const CtrlInventoryItemRect = preload("res://addons/gloot/ui/ctrl_inventory_item_rect.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")
const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

enum SelectMode {SELECT_SINGLE = 0, SELECT_MULTI = 1}

@export var field_dimensions: Vector2 = Vector2(32, 32) :
    set(new_field_dimensions):
        if new_field_dimensions == field_dimensions:
            return
        field_dimensions = new_field_dimensions
        _queue_refresh()
@export var item_spacing: int = 0 :
    set(new_item_spacing):
        if new_item_spacing == item_spacing:
            return
        item_spacing = new_item_spacing
        _queue_refresh()
@export var inventory_path: NodePath :
    set(new_inv_path):
        if new_inv_path == inventory_path:
            return
        inventory_path = new_inv_path
        var node: Node = get_node_or_null(inventory_path)

        if node == null:
            return

        if is_inside_tree():
            assert(node is InventoryGrid)
            
        inventory = node
        update_configuration_warnings()
@export var default_item_texture: Texture2D :
    set(new_default_item_texture):
        if new_default_item_texture == default_item_texture:
            return
        default_item_texture = new_default_item_texture
        _queue_refresh()
@export var stretch_item_sprites: bool = true :
    set(new_stretch_item_sprites):
        stretch_item_sprites = new_stretch_item_sprites
        _queue_refresh()
@export_enum("Single", "Multi") var select_mode: int = SelectMode.SELECT_SINGLE :
    set(new_select_mode):
        if select_mode == new_select_mode:
            return
        select_mode = new_select_mode
        _clear_selection()
var inventory: InventoryGrid = null :
    set(new_inventory):
        if inventory == new_inventory:
            return

        _clear_selection()

        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()

        _queue_refresh()
var _ctrl_item_container: Control = null
var _ctrl_drop_zone: CtrlDropZone = null
var _selected_items: Array[InventoryItem] = []
var _refresh_queued: bool = false


func _get_configuration_warnings() -> PackedStringArray:
    if inventory_path.is_empty():
        return PackedStringArray([
                "This node is not linked to an inventory and it can't display any content.\n" + \
                "Set the inventory_path property to point to an InventoryGrid node."])
    return PackedStringArray()


func _ready() -> void:
    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        if is_instance_valid(_ctrl_item_container):
            _ctrl_item_container.queue_free()

    mouse_filter = Control.MOUSE_FILTER_IGNORE

    _ctrl_item_container = Control.new()
    _ctrl_item_container.size = size
    _ctrl_item_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    resized.connect(func(): _ctrl_item_container.size = size)
    add_child(_ctrl_item_container)

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
    add_child(_ctrl_drop_zone)

    if has_node(inventory_path):
        inventory = get_node_or_null(inventory_path)

    _queue_refresh()


func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_END:
        _ctrl_drop_zone.deactivate()


func _connect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return

    if !inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.connect(_queue_refresh)
    if !inventory.item_property_changed.is_connected(_on_item_property_changed):
        inventory.item_property_changed.connect(_on_item_property_changed)
    if !inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.connect(_on_inventory_resized)
    if !inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.connect(_on_item_removed)


func _disconnect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return

    if inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.disconnect(_queue_refresh)
    if inventory.item_property_changed.is_connected(_on_item_property_changed):
        inventory.item_property_changed.disconnect(_on_item_property_changed)
    if inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.disconnect(_on_inventory_resized)
    if inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.disconnect(_on_item_removed)


func _on_item_property_changed(_item: InventoryItem, property_name: String) -> void:
    var relevant_properties = [
        GridConstraint.KEY_WIDTH,
        GridConstraint.KEY_HEIGHT,
        GridConstraint.KEY_SIZE,
        GridConstraint.KEY_ROTATED,
        GridConstraint.KEY_GRID_POSITION,
        InventoryItem.KEY_IMAGE,
    ]
    if property_name in relevant_properties:
        _queue_refresh()


func _on_inventory_resized() -> void:
    _queue_refresh()


func _on_item_removed(item: InventoryItem) -> void:
    _deselect(item)


func _process(_delta) -> void:
    if _refresh_queued:
        _refresh()
        _refresh_queued = false


func _queue_refresh() -> void:
    _refresh_queued = true


func _refresh() -> void:
    _ctrl_drop_zone.deactivate()
    custom_minimum_size = _get_inventory_size_px()
    size = custom_minimum_size

    _clear_list()
    _populate_list()


func _get_inventory_size_px() -> Vector2:
    if !is_instance_valid(inventory):
        return Vector2.ZERO

    var result := Vector2(inventory.size.x * field_dimensions.x, \
        inventory.size.y * field_dimensions.y)

    # Also take item spacing into consideration
    result += Vector2(inventory.size - Vector2i.ONE) * item_spacing

    return result


func _clear_list() -> void:
    if !is_instance_valid(_ctrl_item_container):
        return

    for ctrl_inventory_item in _ctrl_item_container.get_children():
        _ctrl_item_container.remove_child(ctrl_inventory_item)
        ctrl_inventory_item.queue_free()


func _populate_list() -> void:
    if !is_instance_valid(inventory) || !is_instance_valid(_ctrl_item_container):
        return
        
    for item in inventory.get_items():
        var ctrl_inventory_item = CtrlInventoryItemRect.new()
        ctrl_inventory_item.texture = default_item_texture
        ctrl_inventory_item.item = item
        ctrl_inventory_item.grabbed.connect(_on_item_grab.bind(ctrl_inventory_item))
        ctrl_inventory_item.dropped.connect(_on_item_drop.bind(ctrl_inventory_item))
        ctrl_inventory_item.activated.connect(_on_item_activated.bind(ctrl_inventory_item))
        ctrl_inventory_item.context_activated.connect(_on_item_context_activated.bind(ctrl_inventory_item))
        ctrl_inventory_item.mouse_entered.connect(_on_item_mouse_entered.bind(ctrl_inventory_item))
        ctrl_inventory_item.mouse_exited.connect(_on_item_mouse_exited.bind(ctrl_inventory_item))
        ctrl_inventory_item.clicked.connect(_on_item_clicked.bind(ctrl_inventory_item))
        ctrl_inventory_item.size = _get_item_sprite_size(item)

        ctrl_inventory_item.position = _get_field_position(inventory.get_item_position(item))
        ctrl_inventory_item.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
        if stretch_item_sprites:
            ctrl_inventory_item.stretch_mode = TextureRect.STRETCH_SCALE

        _ctrl_item_container.add_child(ctrl_inventory_item)


func _on_item_grab(offset: Vector2, ctrl_inventory_item: CtrlInventoryItemRect) -> void:
    _clear_selection()


func _on_item_drop(zone: CtrlDropZone, drop_position: Vector2, ctrl_inventory_item: CtrlInventoryItemRect) -> void:
    var item: InventoryItem = ctrl_inventory_item.item
    # The item might have been freed in case the item stack has been moved and merged with another
    # stack.
    if is_instance_valid(item) and inventory.has_item(item):
        if zone == null:
            item_dropped.emit(item, drop_position + ctrl_inventory_item.position)


func _get_item_sprite_size(item: InventoryItem) -> Vector2:
    var item_size := inventory.get_item_size(item)
    var sprite_size := Vector2(item_size) * field_dimensions

    # Also take item spacing into consideration
    sprite_size += (Vector2(item_size) - Vector2.ONE) * item_spacing

    return sprite_size


func _on_item_activated(ctrl_inventory_item: CtrlInventoryItemRect) -> void:
    var item = ctrl_inventory_item.item
    if !item:
        return

    inventory_item_activated.emit(item)


func _on_item_context_activated(ctrl_inventory_item: CtrlInventoryItemRect) -> void:
    var item = ctrl_inventory_item.item
    if !item:
        return

    inventory_item_context_activated.emit(item)


func _on_item_mouse_entered(ctrl_inventory_item) -> void:
    item_mouse_entered.emit(ctrl_inventory_item.item)


func _on_item_mouse_exited(ctrl_inventory_item) -> void:
    item_mouse_exited.emit(ctrl_inventory_item.item)


func _on_item_clicked(ctrl_inventory_item) -> void:
    var item = ctrl_inventory_item.item
    if !is_instance_valid(item):
        return

    if select_mode == SelectMode.SELECT_MULTI && Input.is_key_pressed(KEY_CTRL):
        if !_is_item_selected(item):
            _select(item)
        else:
            _deselect(item)
    else:
        _clear_selection()
        _select(item)


func _select(item: InventoryItem) -> void:
    if item in _selected_items:
        return

    if (item != null) && !inventory.has_item(item):
        return

    _selected_items.append(item)
    selection_changed.emit()


func _is_item_selected(item: InventoryItem) -> bool:
    return item in _selected_items


func _deselect(item: InventoryItem) -> void:
    if !(item in _selected_items):
        return
    var idx := _selected_items.find(item)
    if idx < 0:
        return
    _selected_items.remove_at(idx)
    selection_changed.emit()


func _clear_selection() -> void:
    if _selected_items.is_empty():
        return
    _selected_items.clear()
    selection_changed.emit()


func _on_dragable_dropped(dragable: CtrlDragable, drop_position: Vector2) -> void:
    var item: InventoryItem = dragable.item
    if item == null:
        return

    if !is_instance_valid(inventory):
        return

    if inventory.has_item(item):
        _handle_item_move(item, drop_position)
    else:
        _handle_item_transfer(item, drop_position)


func _handle_item_move(item: InventoryItem, drop_position: Vector2) -> void:
    var field_coords = get_field_coords(drop_position + (field_dimensions / 2))
    if _move_item(item, field_coords):
        return
    if _merge_item(item, field_coords):
        return
    _swap_items(item, field_coords)


func _handle_item_transfer(item: InventoryItem, drop_position: Vector2) -> void:
    var source_inventory: InventoryGrid = item.get_inventory()
    
    var field_coords = get_field_coords(drop_position + (field_dimensions / 2))
    if source_inventory != null:
        if source_inventory.item_protoset != inventory.item_protoset:
            return
        source_inventory.transfer_to(item, inventory, field_coords)
    elif !inventory.add_item_at(item, field_coords):
        _swap_items(item, field_coords)


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
    if _selected_items.is_empty():
        return null
    return _selected_items[0]


func get_selected_inventory_items() -> Array[InventoryItem]:
    return _selected_items.duplicate()


func _move_item(item: InventoryItem, move_position: Vector2i) -> bool:
    if !inventory.rect_free(Rect2i(move_position, inventory.get_item_size(item)), item):
        return false
    if Engine.is_editor_hint():
        GlootUndoRedo.move_inventory_item(inventory, item, move_position)
        return true
    inventory.move_item_to(item, move_position)
    return true

        
func _merge_item(item_src: InventoryItem, position: Vector2i) -> bool:
    if !(inventory is InventoryGridStacked):
        return false

    var item_dst = (inventory as InventoryGridStacked)._get_mergable_item_at(item_src, position)
    if item_dst == null:
        return false

    if Engine.is_editor_hint():
        GlootUndoRedo.join_inventory_items(inventory, item_dst, item_src)
    else:
        (inventory as InventoryGridStacked).join(item_dst, item_src)
    return true


func _swap_items(item: InventoryItem, position: Vector2i) -> bool:
    var item2 = inventory.get_item_at(position)
    if item2 == null:
        return false

    if Engine.is_editor_hint():
        GlootUndoRedo.swap_inventory_items(item, item2)
    else:
        InventoryItem.swap(item, item2)
    return true


func _get_field_position(field_coords: Vector2i) -> Vector2:
    var field_position = Vector2(field_coords.x * field_dimensions.x, \
        field_coords.y * field_dimensions.y)
    field_position += Vector2(item_spacing * field_coords)
    return field_position


func deselect_inventory_item() -> void:
    _clear_selection()


func select_inventory_item(item: InventoryItem) -> void:
    _select(item)


func get_item_rect(item: InventoryItem) -> Rect2:
    if !is_instance_valid(item):
        return Rect2()
    return Rect2(
        _get_field_position(inventory.get_item_position(item)),
        _get_item_sprite_size(item)
    )

