@tool
extends Control

const GlootInventoryFieldGrid = preload("res://addons/gloot/ui/gloot_inventory_field_grid.gd")

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        inventory = get_node_or_null(inventory_path)

@export var field_grid_path: NodePath :
    get:
        return field_grid_path
    set(new_field_grid_path):
        field_grid_path = new_field_grid_path
        field_grid = get_node_or_null(field_grid_path)

var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        if inventory == new_inventory:
            return
        inventory = new_inventory
        if inventory == null:
            return
        if inventory.is_node_ready():
            _refresh()
        else:
            inventory.ready.connect(_refresh)

var field_grid: GlootInventoryFieldGrid = null :
    get:
        return field_grid
    set(new_field_grid):
        if field_grid == new_field_grid:
            return
        field_grid = new_field_grid
        if field_grid == null:
            return
        field_grid.sort_children.connect(_update_item_positions)
        _refresh()


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    if !inventory_path.is_empty():
        inventory = get_node_or_null(inventory_path)
    if !field_grid_path.is_empty():
        field_grid = get_node_or_null(field_grid_path)
    _refresh()

        
func _refresh() -> void:
    _clear()
    _populate()


func _clear() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()


func _populate() -> void:
    if inventory == null || !inventory.is_node_ready() || field_grid == null:
        return

    var grid_constraint := inventory._constraint_manager.get_grid_constraint()
    if grid_constraint == null:
        return

    for item in inventory.get_items():
        var item_rect = _get_item_ui_rect(item)
        var color_rect := ColorRect.new()
        color_rect.position = item_rect.position
        color_rect.size = item_rect.size
        color_rect.modulate = Color(1.0, 1.0, 1.0, 0.25)
        add_child(color_rect)

    custom_minimum_size = field_grid.size


func _update_item_positions() -> void:
    if inventory == null || !inventory.is_node_ready() || field_grid == null:
        return

    assert(inventory.get_item_count() == get_child_count())
    for item_index in range(inventory.get_items().size()):
        var item = inventory.get_items()[item_index]
        var item_rect = _get_item_ui_rect(item)
        var color_rect = get_child(item_index)
        color_rect.position = item_rect.position
        color_rect.size = item_rect.size

    custom_minimum_size = field_grid.size


func _get_item_ui_rect(item: InventoryItem) -> Rect2:
    var grid_constraint := inventory._constraint_manager.get_grid_constraint()
    
    var item_field_rect := grid_constraint.get_item_rect(item)
    var top_left := field_grid.get_field_position(item_field_rect.position)
    var bottom_right := field_grid.get_field_position(item_field_rect.position + item_field_rect.size - Vector2i.ONE)
    bottom_right += field_grid.field_size

    return Rect2(top_left, bottom_right - top_left)
