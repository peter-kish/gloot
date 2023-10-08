@tool
class_name GlootInventoryGrid
extends Control

const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")
const GlootInventoryFieldGrid = preload("res://addons/gloot/ui/gloot_inventory_field_grid.gd")

var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        if inventory == new_inventory:
            return
        inventory = new_inventory
        _refresh()

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        inventory = get_node_or_null(inventory_path)

@export var field_size: Vector2 = Vector2(32, 32) :
    get:
        return field_size
    set(new_field_size):
        field_size = new_field_size
        _refresh()

@export var field_style: StyleBox :
    get:
        return field_style
    set(new_field_style):
        field_style = new_field_style
        _refresh()

@export var field_hover_style: StyleBox :
    get:
        return field_hover_style
    set(new_field_hover_style):
        field_hover_style = new_field_hover_style
        _refresh()

@export var field_selected_style: StyleBox :
    get:
        return field_selected_style
    set(new_field_selected_style):
        field_selected_style = new_field_selected_style
        _refresh()

@export var selection_style: StyleBox :
    get:
        return selection_style
    set(new_selection_style):
        selection_style = new_selection_style
        _refresh()

var _inventory_field_grid: GlootInventoryFieldGrid = null


func _ready() -> void:
    if !inventory_path.is_empty():
        inventory = get_node_or_null(inventory_path)
    _refresh()


func _refresh() -> void:
    _clear()
    _populate()


func _clear() -> void:
    if _inventory_field_grid:
        remove_child(_inventory_field_grid)
        _inventory_field_grid.queue_free()


func _populate() -> void:
    if inventory == null:
        # TODO: Configuration warning
        return

    var grid_constraint: GridConstraint = inventory._constraint_manager.get_grid_constraint()
    if grid_constraint == null:
        # TODO: Configuration warning
        return

    _inventory_field_grid = GlootInventoryFieldGrid.new()
    _inventory_field_grid.inventory = inventory
    _inventory_field_grid.field_size = field_size
    _inventory_field_grid.style = field_style
    _inventory_field_grid.hover_style = field_hover_style
    _inventory_field_grid.selected_style = field_selected_style
    add_child(_inventory_field_grid)

    custom_minimum_size = _inventory_field_grid.size
