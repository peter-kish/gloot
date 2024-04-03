@tool
class_name GlootInventoryGrid
extends Control

# TODO: Consider renaming to item_activated
signal inventory_item_activated(item)
signal inventory_item_context_activated(item)

const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")
const GlootInventoryFieldGrid = preload("res://addons/gloot/ui/gloot_inventory_field_grid.gd")
const GlootInventoryItemGrid = preload("res://addons/gloot/ui/gloot_inventory_item_grid.gd")

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
        if _inventory_field_grid:
            _inventory_field_grid.field_size = field_size

@export var item_spacing: int = 0 :
    get:
        return item_spacing
    set(new_item_spacing):
        item_spacing = max(0, new_item_spacing)
        if _inventory_field_grid == null:
            return
        _update_item_spacing()

@export var field_style: StyleBox :
    get:
        return field_style
    set(new_field_style):
        field_style = new_field_style
        if _inventory_field_grid:
            _inventory_field_grid.style = field_style

@export var field_hover_style: StyleBox :
    get:
        return field_hover_style
    set(new_field_hover_style):
        field_hover_style = new_field_hover_style
        if _inventory_field_grid:
            _inventory_field_grid.hover_style = field_hover_style

@export var field_selected_style: StyleBox :
    get:
        return field_selected_style
    set(new_field_selected_style):
        field_selected_style = new_field_selected_style
        if _inventory_field_grid:
            _inventory_field_grid.selected_style = field_selected_style

@export var selection_style: StyleBox :
    get:
        return selection_style
    set(new_selection_style):
        selection_style = new_selection_style
        if _inventory_item_grid:
            _inventory_item_grid.selection_style = selection_style

var _inventory_field_grid: GlootInventoryFieldGrid = null
var _inventory_item_grid: GlootInventoryItemGrid = null


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
        _inventory_field_grid = null
    if _inventory_item_grid:
        remove_child(_inventory_item_grid)
        _inventory_item_grid.queue_free()
        _inventory_item_grid = null
    custom_minimum_size = Vector2.ZERO
    size = Vector2.ZERO


func _populate() -> void:
    if inventory == null:
        # TODO: Configuration warning
        return

    var grid_constraint: GridConstraint = inventory.get_grid_constraint()
    if grid_constraint == null:
        # TODO: Configuration warning
        return

    _inventory_field_grid = GlootInventoryFieldGrid.new()
    _inventory_field_grid.inventory = inventory
    _inventory_field_grid.field_size = field_size
    _inventory_field_grid.style = field_style
    _inventory_field_grid.hover_style = field_hover_style
    _inventory_field_grid.selected_style = field_selected_style
    _inventory_field_grid.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    _inventory_field_grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    _update_item_spacing()
    _inventory_field_grid.resized.connect(_update_size)
    add_child(_inventory_field_grid)

    _inventory_item_grid = GlootInventoryItemGrid.new()
    _inventory_item_grid.inventory = inventory
    _inventory_item_grid.field_grid = _inventory_field_grid
    _inventory_item_grid.selection_style = selection_style
    _inventory_item_grid.inventory_item_activated.connect(func(item: InventoryItem):
        inventory_item_activated.emit(item)
    )
    _inventory_item_grid.inventory_item_context_activated.connect(func(item: InventoryItem):
        inventory_item_context_activated.emit(item)
    )
    add_child(_inventory_item_grid)

    _update_size()


func _update_size() -> void:
    if _inventory_field_grid == null:
        return
    custom_minimum_size = _inventory_field_grid.size
    size = _inventory_field_grid.size


func _update_item_spacing() -> void:
    if _inventory_field_grid == null:
        return
    _inventory_field_grid.remove_theme_constant_override("h_separation")
    _inventory_field_grid.remove_theme_constant_override("v_separation")
    _inventory_field_grid.add_theme_constant_override("h_separation", item_spacing)
    _inventory_field_grid.add_theme_constant_override("v_separation", item_spacing)


# TODO: Consider renaming to get_selected_item
func get_selected_inventory_item() -> InventoryItem:
    if _inventory_item_grid == null:
        return null
    return _inventory_item_grid.get_selected_item()
