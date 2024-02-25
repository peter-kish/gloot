@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_grid.svg")
class_name CtrlInventoryGrid
extends Control

signal item_dropped(item, offset)
signal selection_changed
signal inventory_item_activated(item)
signal inventory_item_context_activated(item)
signal item_mouse_entered(item)
signal item_mouse_exited(item)

const CtrlInventoryGridBasic = preload("res://addons/gloot/ui/ctrl_inventory_grid_basic.gd")

class GridControl extends Control:
    var color: Color = Color.BLACK :
        set(new_color):
            if new_color == color:
                return
            color = new_color
            queue_redraw()
    var dimensions: Vector2i = Vector2i.ZERO :
        set(new_dimensions):
            if new_dimensions == dimensions:
                return
            dimensions = new_dimensions
            queue_redraw()

    func _init(color_: Color, dimensions_: Vector2i) -> void:
        color = color_
        dimensions = dimensions_

    func _draw() -> void:
        var rect = Rect2(Vector2.ZERO, size)
        draw_rect(rect, color, false)

        if dimensions.x < 1 || dimensions.y < 1:
            return

        for i in range(1, dimensions.x):
            var from: Vector2 = Vector2(i * size.x / dimensions.x, 0)
            var to: Vector2 = Vector2(i * size.x / dimensions.x, size.y)
            draw_line(from, to, color)
        for j in range(1, dimensions.y):
            var from: Vector2 = Vector2(0, j * size.y / dimensions.y)
            var to: Vector2 = Vector2(size.x, j * size.y / dimensions.y)
            draw_line(from, to, color)
        

@export var field_dimensions: Vector2 = Vector2(32, 32) :
    set(new_field_dimensions):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.field_dimensions = new_field_dimensions
        field_dimensions = new_field_dimensions
@export var item_spacing: int = 0 :
    set(new_item_spacing):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.item_spacing = new_item_spacing
        item_spacing = new_item_spacing
@export var draw_grid: bool = true
@export var grid_color: Color = Color.BLACK
@export var draw_selections: bool = false
@export var selection_color: Color = Color.GRAY
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
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.default_item_texture = new_default_item_texture
        default_item_texture = new_default_item_texture
@export var stretch_item_sprites: bool = true :
    set(new_stretch_item_sprites):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.stretch_item_sprites = new_stretch_item_sprites
        stretch_item_sprites = new_stretch_item_sprites
var inventory: InventoryGrid = null :
    set(new_inventory):
        if inventory == new_inventory:
            return

        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()

        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.inventory = inventory
        if is_instance_valid(_ctrl_grid):
            _ctrl_grid.dimensions = _get_inventory_dimensions()

var _ctrl_grid: GridControl = null
var _ctrl_inventory_grid_basic: CtrlInventoryGridBasic = null


func _connect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return
    if !inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.connect(_on_inventory_resized)


func _disconnect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return
    if inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.disconnect(_on_inventory_resized)


func _on_inventory_resized() -> void:
    _ctrl_grid.dimensions = _get_inventory_dimensions()


func _get_configuration_warnings() -> PackedStringArray:
    if inventory_path.is_empty():
        return PackedStringArray([
                "This node is not linked to an inventory and can't display any content.\n" + \
                "Set the inventory_path property to point to an InventoryGrid node."])
    return PackedStringArray()


func _ready() -> void:
    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.queue_free()

    if has_node(inventory_path):
        inventory = get_node_or_null(inventory_path)

    _ctrl_inventory_grid_basic = CtrlInventoryGridBasic.new()
    _ctrl_inventory_grid_basic.inventory = inventory
    _ctrl_inventory_grid_basic.field_dimensions = field_dimensions
    _ctrl_inventory_grid_basic.item_spacing = item_spacing
    _ctrl_inventory_grid_basic.default_item_texture = default_item_texture
    _ctrl_inventory_grid_basic.stretch_item_sprites = stretch_item_sprites
    _ctrl_inventory_grid_basic.name = "CtrlInventoryGridBasic"
    _ctrl_inventory_grid_basic.resized.connect(_update_size)

    _ctrl_grid = GridControl.new(grid_color, _get_inventory_dimensions())
    _ctrl_grid.color = grid_color
    _ctrl_grid.dimensions = _get_inventory_dimensions()
    _ctrl_grid.name = "CtrlGrid"

    add_child(_ctrl_grid)
    add_child(_ctrl_inventory_grid_basic)

    _update_size()


func _get_inventory_dimensions() -> Vector2i:
    var inventory_grid = _get_inventory()
    if !is_instance_valid(inventory_grid):
        return Vector2i.ZERO
    return _ctrl_inventory_grid_basic.inventory.size


func _update_size() -> void:
    custom_minimum_size = _ctrl_inventory_grid_basic.size
    size = _ctrl_inventory_grid_basic.size
    _ctrl_grid.custom_minimum_size = _ctrl_inventory_grid_basic.size
    _ctrl_grid.size = _ctrl_inventory_grid_basic.size


func _get_inventory() -> InventoryGrid:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return null
    if !is_instance_valid(_ctrl_inventory_grid_basic.inventory):
        return null
    return _ctrl_inventory_grid_basic.inventory

