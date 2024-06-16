@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_grid.svg")
class_name CtrlInventoryGrid
extends Control

## A UI control representing a grid-based inventory ([InventoryGrid]).
##
## Displays a grid based on the inventory capacity (width and height) and the
## contained items on the grid. The items can be moved around in the inventory
## by dragging.

## Emitted when a grabbed [InventoryItem] is dropped.
signal item_dropped(item, offset)
## Emitted when the selection has changed. Use [method get_selected_inventory_item]
## to obtain the currently selected item.
signal selection_changed
## Emitted when an [InventoryItem] is activated (i.e. double clicked).
signal inventory_item_activated(item)
## Emitted when the context menu of an [InventoryItem] is activated
## (i.e. right clicked).
signal inventory_item_context_activated(item)
## Emitted when the mouse enters the [Rect2] area of the control representing
## the given [InventoryItem].
signal item_mouse_entered(item)
## Emitted when the mouse leaves the [Rect2] area of the control representing
## the given [InventoryItem].
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
        

## Path to an [Inventory] node.
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

## The default texture that will be used for items with no [code]image[/code]
## property.
@export var default_item_texture: Texture2D :
    set(new_default_item_texture):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.default_item_texture = new_default_item_texture
        default_item_texture = new_default_item_texture

## If true, the inventory item sprites will be stretched to fit the inventory
## fields they are positioned on.
@export var stretch_item_sprites: bool = true :
    set(new_stretch_item_sprites):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.stretch_item_sprites = new_stretch_item_sprites
        stretch_item_sprites = new_stretch_item_sprites

## The size of each inventory field in pixels.
@export var field_dimensions: Vector2 = Vector2(32, 32) :
    set(new_field_dimensions):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.field_dimensions = new_field_dimensions
        field_dimensions = new_field_dimensions

## The spacing between items in pixels.
@export var item_spacing: int = 0 :
    set(new_item_spacing):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.item_spacing = new_item_spacing
        item_spacing = new_item_spacing

## Displays a grid if true.
@export var draw_grid: bool = true :
    set(new_draw_grid):
        if new_draw_grid == draw_grid:
            return
        draw_grid = new_draw_grid
        _queue_refresh()

## The color of the grid.
@export var grid_color: Color = Color.BLACK :
    set(new_grid_color):
        if(new_grid_color == grid_color):
            return
        grid_color = new_grid_color
        _queue_refresh()

## Draws a rectangle behind the selected item if true.
@export var draw_selections: bool = false :
    set(new_draw_selections):
        if new_draw_selections == draw_selections:
            return
        draw_selections = new_draw_selections
        _queue_refresh()

## The color of the selection.
@export var selection_color: Color = Color.GRAY :
    set(new_selection_color):
        if(new_selection_color == selection_color):
            return
        selection_color = new_selection_color
        _queue_refresh()

## Single or multi select mode (hold CTRL to select multiple items).
@export_enum("Single", "Multi") var select_mode: int = CtrlInventoryGridBasic.SelectMode.SELECT_SINGLE :
    set(new_select_mode):
        if select_mode == new_select_mode:
            return
        select_mode = new_select_mode
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.select_mode = select_mode

## The [InventoryGrid] node linked to this control.
var inventory: InventoryGrid = null :
    set(new_inventory):
        if inventory == new_inventory:
            return

        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()

        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.inventory = inventory
        _queue_refresh()

var _ctrl_grid: GridControl = null
var _ctrl_selection: Control = null
var _ctrl_inventory_grid_basic: CtrlInventoryGridBasic = null
var _refresh_queued: bool = false


func _connect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return
    if !inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.connect(_queue_refresh)
    if !inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.connect(_on_inventory_resized)


func _disconnect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return
    if inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.disconnect(_queue_refresh)
    if inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.disconnect(_on_inventory_resized)


func _on_inventory_resized() -> void:
    _queue_refresh()


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
            _ctrl_grid.queue_free()
            _ctrl_selection.queue_free()

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
    _ctrl_inventory_grid_basic.select_mode = select_mode

    _ctrl_inventory_grid_basic.item_dropped.connect(func(item: InventoryItem, drop_position: Vector2):
        item_dropped.emit(item, drop_position)
    )
    _ctrl_inventory_grid_basic.selection_changed.connect(func():
        _queue_refresh()
        selection_changed.emit()
    )
    _ctrl_inventory_grid_basic.inventory_item_activated.connect(func(item: InventoryItem):
        inventory_item_activated.emit(item)
    )
    _ctrl_inventory_grid_basic.inventory_item_context_activated.connect(func(item: InventoryItem):
        inventory_item_context_activated.emit(item)
    )
    _ctrl_inventory_grid_basic.item_mouse_entered.connect(func(item: InventoryItem): item_mouse_entered.emit(item))
    _ctrl_inventory_grid_basic.item_mouse_exited.connect(func(item: InventoryItem): item_mouse_exited.emit(item))

    _ctrl_grid = GridControl.new(grid_color, _get_inventory_dimensions())
    _ctrl_grid.color = grid_color
    _ctrl_grid.dimensions = _get_inventory_dimensions()
    _ctrl_grid.name = "CtrlGrid"

    _ctrl_selection = Control.new()
    _ctrl_selection.visible = draw_selections

    add_child(_ctrl_grid)
    add_child(_ctrl_selection)
    add_child(_ctrl_inventory_grid_basic)

    _update_size()
    _queue_refresh()


func _process(_delta) -> void:
    if _refresh_queued:
        _refresh()
        _refresh_queued = false


func _refresh() -> void:
    if is_instance_valid(_ctrl_grid):
        _ctrl_grid.dimensions = _get_inventory_dimensions()
        _ctrl_grid.color = grid_color
        _ctrl_grid.visible = draw_grid
    else:
        _ctrl_grid.hide()

    if is_instance_valid(_ctrl_selection) && is_instance_valid(_ctrl_inventory_grid_basic):
        for child in _ctrl_selection.get_children():
            child.queue_free()
        for selected_inventory_item in _ctrl_inventory_grid_basic.get_selected_inventory_items():
            var rect := _ctrl_inventory_grid_basic.get_item_rect(selected_inventory_item)
            var selection_rect := ColorRect.new()
            selection_rect.color = selection_color
            selection_rect.position = rect.position
            selection_rect.size = rect.size
            _ctrl_selection.add_child(selection_rect)
            _ctrl_selection.visible = draw_selections


func _queue_refresh() -> void:
    _refresh_queued = true


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

## Deselects the selected item.
func deselect_inventory_item() -> void:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return
    _ctrl_inventory_grid_basic.deselect_inventory_item()

## Selects the given item.
func select_inventory_item(item: InventoryItem) -> void:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return
    _ctrl_inventory_grid_basic.select_inventory_item(item)

## Returns the currently selected item. In case multiple items are selected,
## the first one is returned.
func get_selected_inventory_item() -> InventoryItem:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return null
    return _ctrl_inventory_grid_basic.get_selected_inventory_item()

## Returns all the currently selected items.
func get_selected_inventory_items() -> Array[InventoryItem]:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return []
    return _ctrl_inventory_grid_basic.get_selected_inventory_items()

