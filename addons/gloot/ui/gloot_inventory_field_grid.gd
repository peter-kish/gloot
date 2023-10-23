@tool
extends GridContainer

const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")
const GlootInventoryField = preload("res://addons/gloot/ui/gloot_inventory_field.gd")

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        inventory = get_node_or_null(inventory_path)

@export var style: StyleBox :
    get:
        return style
    set(new_style):
        style = new_style
        _update_style(style)

@export var hover_style: StyleBox :
    get:
        return hover_style
    set(new_hover_style):
        hover_style = new_hover_style
        _update_hover_style(hover_style)

@export var selected_style: StyleBox :
    get:
        return selected_style
    set(new_selected_style):
        selected_style = new_selected_style
        _update_selected_style(selected_style)

@export var field_size: Vector2 = Vector2(32, 32) :
    get:
        return field_size
    set(new_field_size):
        field_size = new_field_size
        _update_field_size(field_size)

var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        if inventory == new_inventory:
            return

        if new_inventory == null:
            _disconnect_inventory_signals()
            inventory = null
            _clear()
            return

        inventory = new_inventory
        if inventory.is_node_ready():
            _refresh()
        _connect_inventory_signals()


func _connect_inventory_signals() -> void:
    if !inventory.is_node_ready():
        inventory.ready.connect(_refresh)
    inventory.contents_changed.connect(_refresh)
    inventory.protoset_changed.connect(_refresh)


func _disconnect_inventory_signals() -> void:
    if inventory.ready.is_connected(_refresh):
        inventory.ready.disconnect(_refresh)
    inventory.contents_changed.disconnect(_refresh)
    inventory.protoset_changed.disconnect(_refresh)


func _ready() -> void:
    if !inventory_path.is_empty():
        inventory = get_node_or_null(inventory_path)


func _refresh() -> void:
    _clear()
    _populate()


func _clear() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()


func _populate() -> void:
    if inventory == null:
        return
        
    var grid_constraint := inventory._constraint_manager.get_grid_constraint()
    if grid_constraint == null:
        return

    columns = grid_constraint.size.x

    for i in range(grid_constraint.size.x * grid_constraint.size.y):
        var field := GlootInventoryField.new()
        field.style = style
        field.hover_style = hover_style
        field.selected_style = selected_style
        field.custom_minimum_size = field_size
        field.item_dropped.connect(_on_item_dropped.bind(i))
        add_child(field)


func _on_item_dropped(item: InventoryItem, index: int) -> void:
    if inventory == null:
        return
        
    var dst_grid_constraint := inventory._constraint_manager.get_grid_constraint()
    if dst_grid_constraint == null:
        return

    var src_inventory = item.get_inventory()
    if src_inventory == null:
        return

    var field_coords := Vector2i(index % dst_grid_constraint.size.x, index / dst_grid_constraint.size.x)
    if src_inventory == inventory:
        dst_grid_constraint.move_item_to(item, field_coords)
    else:
        if src_inventory == null:
            return
        var src_grid_constraint = src_inventory._constraint_manager.get_grid_constraint()
        if src_grid_constraint == null:
            return
        src_grid_constraint.transfer_to(item, dst_grid_constraint, field_coords)


func _update_style(new_style: StyleBox) -> void:
    for child in get_children():
        (child as GlootInventoryField).style = new_style


func _update_hover_style(new_hover_style: StyleBox) -> void:
    for child in get_children():
        (child as GlootInventoryField).hover_style = new_hover_style


func _update_selected_style(new_selected_style: StyleBox) -> void:
    for child in get_children():
        (child as GlootInventoryField).selected_style = new_selected_style


func _update_field_size(new_field_size: Vector2) -> void:
    var grid_constraint := inventory._constraint_manager.get_grid_constraint()
    if grid_constraint == null:
        return

    for child in get_children():
        (child as GlootInventoryField).custom_minimum_size = new_field_size


func get_field_position(field_coords: Vector2i) -> Vector2:
    if get_child_count() == 0:
        return Vector2.ZERO
    var field_index := field_coords.y * columns + field_coords.x
    field_index = min(field_index, get_child_count() - 1)
    var field = get_children()[field_index]
    return field.position

