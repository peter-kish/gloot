@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_grid.svg")
class_name CtrlInventoryGridEx
extends Control

# highlight hovered fields
#   on field hover
# highlight hovered items
#   on item hover
# highlight selections
#   on item select

# highlight grabbed item
#   on mouse motion & grabbed item

signal item_mouse_entered(item)
signal item_mouse_exited(item)

const Verify = preload("res://addons/gloot/core/verify.gd")
const CtrlInventoryGridBasic = preload("res://addons/gloot/ui/ctrl_inventory_grid_basic.gd")
const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")


class CustomizablePanel extends Panel:
    var regular_style: StyleBox
    var hover_style: StyleBox
    var persistent_style: StyleBox :
        set(new_persistent_style):
            if new_persistent_style == persistent_style:
                return
            persistent_style = new_persistent_style
            _set_style(persistent_style)


    func _init(regular_style_: StyleBox, hover_style_: StyleBox):
        regular_style = regular_style_
        hover_style = hover_style_


    func _ready():
        _set_style(regular_style)
        mouse_entered.connect(func():
            if persistent_style == null:
                _set_style(hover_style)
        )
        mouse_exited.connect(func():
            if persistent_style == null:
                _set_style(regular_style)
        )


    func _set_style(style: StyleBox):
        remove_theme_stylebox_override("panel")
        if style != null:
            add_theme_stylebox_override("panel", style)


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

@export_group("Custom Styles")
@export var field_style: StyleBox :
    set(new_field_style):
        field_style = new_field_style
        _queue_refresh()
@export var field_highlighted_style: StyleBox :
    set(new_field_highlighted_style):
        field_highlighted_style = new_field_highlighted_style
        _queue_refresh()
@export var field_selected_style: StyleBox :
    set(new_field_selected_style):
        field_selected_style = new_field_selected_style
        _queue_refresh()
@export var selection_style: StyleBox :
    set(new_selection_style):
        selection_style = new_selection_style
        _queue_refresh()

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
var _ctrl_inventory_grid_basic: CtrlInventoryGridBasic = null
var _field_background_grid: Control
var _field_backgrounds: Array
var _selection_panel: Panel
var _refresh_queued: bool = false


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


func _process(_delta) -> void:
    if _refresh_queued:
        _refresh()
        _refresh_queued = false


func _refresh() -> void:
    _refresh_field_background_grid()


func _queue_refresh() -> void:
    _refresh_queued = true


# func _refresh_selection_panel() -> void:
#     if !is_instance_valid(_selection_panel):
#         return
#     var selected_item = _ctrl_inventory_grid_basic.get_selected_inventory_item()
#     _selection_panel.visible = (selected_item != null) && (selection_style != null)
#     if !selected_item:
#         return
#     move_child(_selection_panel, get_child_count() - 1)

#     var r := _ctrl_inventory_grid_basic.get_item_rect(_ctrl_inventory_grid_basic.get_selected_inventory_item())
#     _selection_panel.position = r.position
#     _selection_panel.size = r.size


# func _create_selection_panel() -> void:
#     if !is_instance_valid(_selection_panel):
#         return
#     _selection_panel = Panel.new()
#     var selected_item = _ctrl_inventory_grid_basic.get_selected_inventory_item()
#     add_child(_selection_panel);
#     move_child(_selection_panel, get_child_count() - 1)
#     _set_panel_style(_selection_panel, selection_style)
#     _selection_panel.visible = (selected_item != null) && (selection_style != null)
#     _selection_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
#     _selection_panel.mouse_entered.connect(func(): item_mouse_entered.emit(selected_item))
#     _selection_panel.mouse_exited.connect(func(): item_mouse_exited.emit(selected_item))


func _refresh_field_background_grid() -> void:
    if is_instance_valid(_field_background_grid):
        while _field_background_grid.get_child_count() > 0:
            _field_background_grid.get_children()[0].queue_free()
            _field_background_grid.remove_child(_field_background_grid.get_children()[0])
    _field_backgrounds = []

    if !is_instance_valid(inventory):
        return

    for i in range(inventory.size.x):
        _field_backgrounds.append([])
        for j in range(inventory.size.y):
            var field_panel: CustomizablePanel = CustomizablePanel.new(field_style, field_highlighted_style)
            field_panel.visible = (field_style != null)
            field_panel.size = field_dimensions
            field_panel.position = _ctrl_inventory_grid_basic._get_field_position(Vector2i(i, j))
            _field_background_grid.add_child(field_panel)
            _field_backgrounds[i].append(field_panel)


# func _set_panel_style(panel: Panel, style: StyleBox) -> void:
#     panel.remove_theme_stylebox_override("panel")
#     if style != null:
#         panel.add_theme_stylebox_override("panel", style)


func _ready() -> void:
    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.queue_free()
            _field_background_grid.queue_free()

    if has_node(inventory_path):
        inventory = get_node_or_null(inventory_path)

    # _create_selection_panel()
    _field_background_grid = Control.new()
    _field_background_grid.name = "Field Backgrounds"
    add_child(_field_background_grid)

    _ctrl_inventory_grid_basic = CtrlInventoryGridBasic.new()
    _ctrl_inventory_grid_basic.inventory = inventory
    _ctrl_inventory_grid_basic.field_dimensions = field_dimensions
    _ctrl_inventory_grid_basic.item_spacing = item_spacing
    _ctrl_inventory_grid_basic.default_item_texture = default_item_texture
    _ctrl_inventory_grid_basic.stretch_item_sprites = stretch_item_sprites
    _ctrl_inventory_grid_basic.name = "CtrlInventoryGridBasic"
    _ctrl_inventory_grid_basic.resized.connect(_update_size)
    _ctrl_inventory_grid_basic.selection_changed.connect(_on_selection_changed)
    add_child(_ctrl_inventory_grid_basic)

    _update_size()
    _queue_refresh()


func _update_size() -> void:
    custom_minimum_size = _ctrl_inventory_grid_basic.size
    size = _ctrl_inventory_grid_basic.size


func _on_selection_changed() -> void:
    if !is_instance_valid(inventory):
        return
    if !field_selected_style:
        return
    # for item in inventory.get_items():
    #     if item == _ctrl_inventory_grid_basic.get_selected_inventory_item():
    #         _queue_highlight(inventory.get_item_rect(item), field_selected_style)
    #     else:
    #         _queue_highlight(inventory.get_item_rect(item), field_style)


func _on_inventory_resized() -> void:
    _refresh_field_background_grid()


# func _input(event) -> void:
#     if !(event is InputEventMouseMotion):
#         return
#     if !is_instance_valid(inventory):
#         return
    
#     var hovered_field_coords := Vector2i(-1, -1)
#     if _is_hovering(get_local_mouse_position()):
#         hovered_field_coords = _ctrl_inventory_grid_basic.get_field_coords(get_local_mouse_position())

#     # _reset_highlights()
#     if !field_highlighted_style:
#         return
#     if _highlight_grabbed_item(field_highlighted_style):
#         return
#     _highlight_hovered_fields(hovered_field_coords, field_highlighted_style)


# func _highlight_hovered_fields(field_coords: Vector2i, style: StyleBox) -> void:
#     if !style || !Verify.vector_positive(field_coords):
#         return

#     if _highlight_item(inventory.get_item_at(field_coords), style):
#         return

#     _highlight_field(field_coords, style)


# func _highlight_grabbed_item(style: StyleBox) -> bool:
#     var grabbed_item: InventoryItem = _get_global_grabbed_item()
#     if !grabbed_item:
#         return false

#     var global_grabbed_item_pos: Vector2 = _get_global_grabbed_item_local_pos()
#     if !_is_hovering(global_grabbed_item_pos):
#         return false

#     var grabbed_item_coords := _ctrl_inventory_grid_basic.get_field_coords(global_grabbed_item_pos + (field_dimensions / 2))
#     var item_size := inventory.get_item_size(grabbed_item)
#     var rect := Rect2i(grabbed_item_coords, item_size)
#     _highlight_rect(rect, style, true)
#     return true


# func _is_hovering(local_pos: Vector2) -> bool:
#     return get_rect().has_point(local_pos)


# func _highlight_item(item: InventoryItem, style: StyleBox) -> bool:
#     if !item || !style:
#         return false
#     if item == _ctrl_inventory_grid_basic.get_selected_inventory_item():
#         # Don't highlight the selected item (done in _on_selection_changed())
#         return false

#     _highlight_rect(inventory.get_item_rect(item), style, true)
#     return true


# func _highlight_field(field_coords: Vector2i, style: StyleBox) -> void:
#     var selected_item := _ctrl_inventory_grid_basic.get_selected_inventory_item()
#     if selected_item && inventory.get_item_rect(selected_item).has_point(field_coords):
#         # Don't highlight selected fields (done in _on_selection_changed())
#         return

#     _highlight_rect(Rect2i(field_coords, Vector2i.ONE), style, true)


# func _highlight_rect(rect: Rect2i, style: StyleBox, queue_for_reset: bool) -> void:
#     var h_range = min(rect.size.x + rect.position.x, inventory.size.x)
#     for i in range(rect.position.x, h_range):
#         var v_range = min(rect.size.y + rect.position.y, inventory.size.y)
#         for j in range(rect.position.y, v_range):
#             _set_panel_style(_field_backgrounds[i][j], style)
#     if queue_for_reset:
#         _queue_highlight(rect, field_style)


# func _get_global_grabbed_item() -> InventoryItem:
#     if CtrlDragable.get_grabbed_dragable() == null:
#         return null
#     return (CtrlDragable.get_grabbed_dragable() as CtrlInventoryItemRect).item


# func _get_global_grabbed_item_local_pos() -> Vector2:
#     if CtrlDragable.get_grabbed_dragable():
#         return get_local_mouse_position() - CtrlDragable.get_grab_offset()
#     return Vector2(-1, -1)


func get_selected_inventory_item() -> InventoryItem:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return null
    return _ctrl_inventory_grid_basic.get_selected_inventory_item()
    
