@tool
extends Control

signal item_dropped(item: InventoryItem, offset: Vector2)
signal selection_changed
signal inventory_item_activated(item: InventoryItem)
signal inventory_item_clicked(item: InventoryItem)
signal inventory_item_selected(item: InventoryItem)
signal item_mouse_entered(item: InventoryItem)
signal item_mouse_exited(item: InventoryItem)

const _Undoables = preload("res://addons/gloot/editor/undoables.gd")
const _CtrlDraggableInventoryItem = preload("res://addons/gloot/ui/ctrl_draggable_inventory_item.gd")
const _Utils = preload("res://addons/gloot/core/utils.gd")
const _StackManager = preload("res://addons/gloot/core/stack_manager.gd")

@export var inventory: Inventory = null:
    set(new_inventory):
        if inventory == new_inventory:
            return

        _clear_selection()

        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()

        _queue_refresh()
@export var field_dimensions: Vector2 = Vector2(32, 32):
    set(new_field_dimensions):
        if new_field_dimensions == field_dimensions:
            return
        field_dimensions = new_field_dimensions
        _queue_refresh()
@export var item_spacing: int = 0:
    set(new_item_spacing):
        if new_item_spacing == item_spacing:
            return
        item_spacing = new_item_spacing
        _queue_refresh()
@export var stretch_item_icons: bool = true:
    set(new_stretch_item_icons):
        stretch_item_icons = new_stretch_item_icons
        _queue_refresh()
@export_enum("Single", "Multi") var select_mode: int = ItemList.SelectMode.SELECT_SINGLE:
    set(new_select_mode):
        if select_mode == new_select_mode:
            return
        select_mode = new_select_mode
        _clear_selection()
@export var custom_item_control_scene: PackedScene = null:
    set(new_custom_item_control_scene):
        if new_custom_item_control_scene == custom_item_control_scene:
            return
        custom_item_control_scene = new_custom_item_control_scene
        _queue_refresh()
@export var drag_tint := Color.WHITE

var _ctrl_item_container: Control = null
var _selected_items: Array[InventoryItem] = []
var _refresh_queued: bool = false


func _ready() -> void:
    _ctrl_item_container = Control.new()
    _ctrl_item_container.size = size
    _ctrl_item_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    resized.connect(func(): _ctrl_item_container.size = size)
    add_child(_ctrl_item_container)

    _queue_refresh()


func _connect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return

    _Utils.safe_connect(inventory.item_property_changed, _on_item_property_changed)
    _Utils.safe_connect(inventory.constraint_changed, _on_constraint_changed)
    _Utils.safe_connect(inventory.item_added, _on_item_added)
    _Utils.safe_connect(inventory.item_removed, _on_item_removed)


func _disconnect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return

    _Utils.safe_disconnect(inventory.item_property_changed, _on_item_property_changed)
    _Utils.safe_disconnect(inventory.constraint_changed, _on_constraint_changed)
    _Utils.safe_disconnect(inventory.item_added, _on_item_added)
    _Utils.safe_disconnect(inventory.item_removed, _on_item_removed)


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
    _queue_refresh()


func _on_item_property_changed(_item: InventoryItem, property: String) -> void:
    var relevant_properties := [
        GridConstraint._KEY_SIZE,
        GridConstraint._KEY_ROTATED,
        GridConstraint._KEY_POSITIVE_ROTATION,
        Inventory._KEY_STACK_SIZE,
        InventoryItem._KEY_IMAGE,
    ]
    if property in relevant_properties:
        _queue_refresh()


func _on_inventory_resized() -> void:
    _queue_refresh()


func _on_item_added(item: InventoryItem) -> void:
    _queue_refresh()


func _on_item_removed(item: InventoryItem) -> void:
    _deselect(item)
    _queue_refresh()


func _process(_delta) -> void:
    if _refresh_queued:
        _refresh()
        _refresh_queued = false


func _queue_refresh() -> void:
    _refresh_queued = true


func _refresh() -> void:
    _clear_list()
    if !is_instance_valid(inventory):
        return

    custom_minimum_size = _get_inventory_size_px()
    size = custom_minimum_size
    _populate_list()


func _get_inventory_size_px() -> Vector2:
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    if !is_instance_valid(inventory) || grid_constraint == null:
        return Vector2.ZERO

    var inv_size := grid_constraint.size
    var result := Vector2(inv_size.x * field_dimensions.x, inv_size.y * field_dimensions.y)

    # Also take item spacing into consideration
    result += Vector2(inv_size - Vector2i.ONE) * item_spacing

    return result


func _clear_list() -> void:
    if !is_instance_valid(_ctrl_item_container):
        return

    for ctrl_draggable_inventory_item in _ctrl_item_container.get_children():
        _ctrl_item_container.remove_child(ctrl_draggable_inventory_item)
        ctrl_draggable_inventory_item.queue_free()


func _populate_list() -> void:
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    if !is_instance_valid(inventory) || (!is_instance_valid(grid_constraint)) || !is_instance_valid(_ctrl_item_container):
        return
        
    for item in inventory.get_items():
        var ctrl_draggable_inventory_item = _CtrlDraggableInventoryItem.new()
        ctrl_draggable_inventory_item.item = item
        ctrl_draggable_inventory_item.ctrl_inventory_item_scene = custom_item_control_scene
        ctrl_draggable_inventory_item.activated.connect(_on_inventory_item_activated.bind(ctrl_draggable_inventory_item))
        ctrl_draggable_inventory_item.clicked.connect(_on_inventory_item_clicked.bind(ctrl_draggable_inventory_item))
        ctrl_draggable_inventory_item.mouse_entered.connect(_on_item_mouse_entered.bind(ctrl_draggable_inventory_item))
        ctrl_draggable_inventory_item.mouse_exited.connect(_on_item_mouse_exited.bind(ctrl_draggable_inventory_item))
        ctrl_draggable_inventory_item.size = _get_item_sprite_size(item)

        ctrl_draggable_inventory_item.position = _get_field_position(grid_constraint.get_item_position(item))
        ctrl_draggable_inventory_item.icon_stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
        if stretch_item_icons:
            ctrl_draggable_inventory_item.icon_stretch_mode = TextureRect.STRETCH_SCALE
        ctrl_draggable_inventory_item.drag_tint = drag_tint

        _ctrl_item_container.add_child(ctrl_draggable_inventory_item)


func _notification(what):
    if what == NOTIFICATION_DRAG_BEGIN:
        _clear_selection()
        for c in _ctrl_item_container.get_children():
            c.mouse_filter = Control.MOUSE_FILTER_IGNORE
    elif what == NOTIFICATION_DRAG_END:
        for c in _ctrl_item_container.get_children():
            c.mouse_filter = Control.MOUSE_FILTER_PASS


func _can_drop_data(at_position: Vector2, data) -> bool:
    return data is InventoryItem


func _drop_data(at_position: Vector2, data) -> void:
    var local_offset := _CtrlDraggableInventoryItem.get_grab_offset_local_to(self)
    at_position -= local_offset
    var item := (data as InventoryItem)
    if is_instance_valid(item):
        _on_item_dropped(item, at_position)


func _get_item_sprite_size(item: InventoryItem) -> Vector2:
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    var item_size := grid_constraint.get_item_size(item)
    var sprite_size := Vector2(item_size) * field_dimensions

    # Also take item spacing into consideration
    sprite_size += (Vector2(item_size) - Vector2.ONE) * item_spacing

    return sprite_size


func _on_inventory_item_clicked(at_position: Vector2,
        button_index: int,
        ctrl_draggable_inventory_item: _CtrlDraggableInventoryItem) -> void:
    var item = ctrl_draggable_inventory_item.item
    if !is_instance_valid(item):
        return

    if select_mode == ItemList.SelectMode.SELECT_MULTI && Input.is_key_pressed(KEY_CTRL):
        if !_is_item_selected(item):
            _select(item)
        else:
            _deselect(item)
    else:
        _clear_selection()
        _select(item)

    inventory_item_clicked.emit(item, at_position, button_index)


func _on_inventory_item_activated(ctrl_draggable_inventory_item: _CtrlDraggableInventoryItem) -> void:
    var item = ctrl_draggable_inventory_item.item
    if !item:
        return

    inventory_item_activated.emit(item)


func _on_item_mouse_entered(ctrl_draggable_inventory_item) -> void:
    item_mouse_entered.emit(ctrl_draggable_inventory_item.item)


func _on_item_mouse_exited(ctrl_draggable_inventory_item) -> void:
    item_mouse_exited.emit(ctrl_draggable_inventory_item.item)


func _select(item: InventoryItem) -> void:
    if item in _selected_items:
        return

    if (item != null) && !inventory.has_item(item):
        return

    _selected_items.append(item)
    inventory_item_selected.emit(item)
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


func _on_item_dropped(item: InventoryItem, drop_position: Vector2) -> void:
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
    var source_inventory: Inventory = item.get_inventory()
    
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    var field_coords = get_field_coords(drop_position + (field_dimensions / 2))
    if source_inventory != null:
        if source_inventory.protoset != inventory.protoset:
            return
        if grid_constraint.add_item_at(item, field_coords):
            return
        if _merge_item(item, field_coords):
            return
        _swap_items(item, field_coords)
    elif !grid_constraint.add_item_at(item, field_coords):
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
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    if !grid_constraint.rect_free(Rect2i(move_position, grid_constraint.get_item_size(item)), item):
        return false
    if Engine.is_editor_hint():
        _Undoables.undoable_action(inventory, "Move Inventory Item", func():
            return grid_constraint.move_item_to(item, move_position)
        )
        return true
    grid_constraint.move_item_to(item, move_position)
    return true

        
func _merge_item(item_src: InventoryItem, position: Vector2i) -> bool:
    var item_dst = _get_mergable_item_at(item_src, position)
    if item_dst == null:
        return false

    if Engine.is_editor_hint():
        _Undoables.undoable_action(inventory, "Merge Inventory Items", func():
            return inventory.merge_stacks(item_dst, item_src, true)
        )
    else:
        inventory.merge_stacks(item_dst, item_src, true)
    return true


func _get_mergable_item_at(item: InventoryItem, position: Vector2i) -> InventoryItem:
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    var target_item := grid_constraint.get_item_at(position)
    if target_item != null && item.can_merge_into(target_item, true):
        return target_item
    return null


func _swap_items(item: InventoryItem, position: Vector2i) -> bool:
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    var item2 := grid_constraint.get_item_at(position)
    if item2 == null:
        return false

    if Engine.is_editor_hint():
        var inventories: Array[Inventory]
        if is_instance_valid(item.get_inventory()):
            inventories.append(item.get_inventory())
        if is_instance_valid(item2.get_inventory()):
            inventories.append(item2.get_inventory())
        _Undoables.undoable_action(inventories, "Swap Inventory Items", func():
            if !_StackManager.stacks_compatible(item, item2):
                InventoryItem.swap(item, item2)
            return true
        )
    else:
        if !_StackManager.stacks_compatible(item, item2):
            InventoryItem.swap(item, item2)
    return true


func _get_field_position(field_coords: Vector2i) -> Vector2:
    var field_position = Vector2(field_coords.x * field_dimensions.x, \
        field_coords.y * field_dimensions.y)
    field_position += Vector2(item_spacing * field_coords)
    return field_position


func deselect_inventory_items() -> void:
    _clear_selection()


func select_inventory_item(item: InventoryItem) -> void:
    _select(item)


func get_item_rect(item: InventoryItem) -> Rect2:
    if !is_instance_valid(item):
        return Rect2()
    return Rect2(
        _get_field_position(inventory.get_constraint(GridConstraint).get_item_position(item)),
        _get_item_sprite_size(item)
    )
