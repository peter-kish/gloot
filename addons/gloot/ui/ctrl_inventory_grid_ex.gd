@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_grid.svg")
class_name CtrlInventoryGridEx
extends Control

## A UI control similar to [CtrlInventoryGrid] but with extended options for
## customization.

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

const Verify = preload("res://addons/gloot/core/verify.gd")
const CtrlInventoryGridBasic = preload("res://addons/gloot/ui/ctrl_inventory_grid_basic.gd")
const CtrlInventoryItemRect = preload("res://addons/gloot/ui/ctrl_inventory_item_rect.gd")
const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")


class PriorityPanel extends Panel:
    enum StylePriority {HIGH = 0, MEDIUM = 1, LOW = 2}

    var regular_style: StyleBox
    var hover_style: StyleBox
    var _styles: Array[StyleBox] = [null, null, null]


    func _init(regular_style_: StyleBox, hover_style_: StyleBox) -> void:
        regular_style = regular_style_
        hover_style = hover_style_


    func _ready() -> void:
        set_style(regular_style)
        mouse_entered.connect(func():
            set_style(hover_style)
        )
        mouse_exited.connect(func():
            set_style(regular_style)
        )


    func set_style(style: StyleBox, priority: int = StylePriority.LOW) -> void:
        if priority > 2 || priority < 0:
            return
        if _styles[priority] == style:
            return

        _styles[priority] = style

        for i in range(0, 3):
            if _styles[i] != null:
                _set_panel_style(_styles[i])
                return


    func _set_panel_style(style: StyleBox) -> void:
        remove_theme_stylebox_override("panel")
        if style != null:
            add_theme_stylebox_override("panel", style)


class SelectionPanel extends Panel:
    func set_style(style: StyleBox) -> void:
        remove_theme_stylebox_override("panel")
        if style != null:
            add_theme_stylebox_override("panel", style)

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

## Single or multi select mode (hold CTRL to select multiple items).
@export_enum("Single", "Multi") var select_mode: int = CtrlInventoryGridBasic.SelectMode.SELECT_SINGLE :
    set(new_select_mode):
        if select_mode == new_select_mode:
            return
        select_mode = new_select_mode
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.select_mode = select_mode

@export_group("Custom Styles")
## Style of a single inventory field.
@export var field_style: StyleBox :
    set(new_field_style):
        field_style = new_field_style
        _queue_refresh()

## Style of a single inventory field when the mouse hovers over it.
@export var field_highlighted_style: StyleBox :
    set(new_field_highlighted_style):
        field_highlighted_style = new_field_highlighted_style
        _queue_refresh()

## Style of a single inventory field when the item on top of it is selected.
@export var field_selected_style: StyleBox :
    set(new_field_selected_style):
        field_selected_style = new_field_selected_style
        _queue_refresh()

## Style of a rectangle that will be drawn on top of the selected item.
@export var selection_style: StyleBox :
    set(new_selection_style):
        selection_style = new_selection_style
        _queue_refresh()

## The [Inventory] node linked to this control.
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
var _field_background_grid: Control = null
var _field_backgrounds: Array = []
var _selection_panels: Control = null
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


func _process(_delta) -> void:
    if _refresh_queued:
        _refresh()
        _refresh_queued = false


func _refresh() -> void:
    _refresh_field_background_grid()
    _refresh_selection_panel()


func _queue_refresh() -> void:
    _refresh_queued = true


func _refresh_selection_panel() -> void:
    if !is_instance_valid(_selection_panels):
        return

    for child in _selection_panels.get_children():
        child.queue_free()

    var selected_items := _ctrl_inventory_grid_basic.get_selected_inventory_items()
    _selection_panels.visible = (!selected_items.is_empty()) && (selection_style != null)
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        var selection_panel := SelectionPanel.new()
        var rect := _ctrl_inventory_grid_basic.get_item_rect(selected_item)
        selection_panel.position = rect.position
        selection_panel.size = rect.size
        selection_panel.set_style(selection_style)
        selection_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _selection_panels.add_child(selection_panel)


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
            var field_panel: PriorityPanel = PriorityPanel.new(field_style, field_highlighted_style)
            field_panel.visible = (field_style != null)
            field_panel.size = field_dimensions
            field_panel.position = _ctrl_inventory_grid_basic._get_field_position(Vector2i(i, j))
            _field_background_grid.add_child(field_panel)
            _field_backgrounds[i].append(field_panel)


func _ready() -> void:
    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.queue_free()
            _field_background_grid.queue_free()

    if has_node(inventory_path):
        inventory = get_node_or_null(inventory_path)

    _field_background_grid = Control.new()
    _field_background_grid.name = "FieldBackgrounds"
    add_child(_field_background_grid)

    _ctrl_inventory_grid_basic = CtrlInventoryGridBasic.new()
    _ctrl_inventory_grid_basic.inventory = inventory
    _ctrl_inventory_grid_basic.field_dimensions = field_dimensions
    _ctrl_inventory_grid_basic.item_spacing = item_spacing
    _ctrl_inventory_grid_basic.default_item_texture = default_item_texture
    _ctrl_inventory_grid_basic.stretch_item_sprites = stretch_item_sprites
    _ctrl_inventory_grid_basic.name = "CtrlInventoryGridBasic"
    _ctrl_inventory_grid_basic.resized.connect(_update_size)
    _ctrl_inventory_grid_basic.item_dropped.connect(func(item: InventoryItem, drop_position: Vector2):
        item_dropped.emit(item, drop_position)
    )
    _ctrl_inventory_grid_basic.inventory_item_activated.connect(func(item: InventoryItem):
        inventory_item_activated.emit(item)
    )
    _ctrl_inventory_grid_basic.inventory_item_context_activated.connect(func(item: InventoryItem):
        inventory_item_context_activated.emit(item)
    )
    _ctrl_inventory_grid_basic.item_mouse_entered.connect(_on_item_mouse_entered)
    _ctrl_inventory_grid_basic.item_mouse_exited.connect(_on_item_mouse_exited)
    _ctrl_inventory_grid_basic.selection_changed.connect(_on_selection_changed)
    _ctrl_inventory_grid_basic.select_mode = select_mode
    add_child(_ctrl_inventory_grid_basic)

    _selection_panels = Control.new()
    _selection_panels.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _selection_panels.name = "SelectionPanels"
    add_child(_selection_panels)

    CtrlDragable.dragable_dropped.connect(func(_grabbed_dragable, _zone, _local_drop_position):
        _fill_background(field_style, PriorityPanel.StylePriority.LOW)
    )

    _update_size()
    _queue_refresh()


func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_END:
        _fill_background(field_style, PriorityPanel.StylePriority.LOW)


func _update_size() -> void:
    custom_minimum_size = _ctrl_inventory_grid_basic.size
    size = _ctrl_inventory_grid_basic.size


func _on_item_mouse_entered(item: InventoryItem) -> void:
    _set_item_background(item, field_highlighted_style, PriorityPanel.StylePriority.MEDIUM)
    item_mouse_entered.emit(item)


func _on_item_mouse_exited(item: InventoryItem) -> void:
    _set_item_background(item, null, PriorityPanel.StylePriority.MEDIUM)
    item_mouse_exited.emit(item)


func _on_selection_changed() -> void:
    _handle_selection_change()
    selection_changed.emit()


func _handle_selection_change() -> void:
    if !is_instance_valid(inventory):
        return
    _refresh_selection_panel()

    if !field_selected_style:
        return
    for item in inventory.get_items():
        if item in _ctrl_inventory_grid_basic.get_selected_inventory_items():
            _set_item_background(item, field_selected_style, PriorityPanel.StylePriority.HIGH)
        else:
            _set_item_background(item, null, PriorityPanel.StylePriority.HIGH)


func _on_inventory_resized() -> void:
    _refresh_field_background_grid()


func _input(event) -> void:
    if !(event is InputEventMouseMotion):
        return
    if !is_instance_valid(inventory):
        return
    
    if !field_highlighted_style:
        return
    _highlight_grabbed_item(field_highlighted_style)


func _highlight_grabbed_item(style: StyleBox):
    var grabbed_item: InventoryItem = _get_global_grabbed_item()
    if !grabbed_item:
        return

    var global_grabbed_item_pos: Vector2 = _get_global_grabbed_item_local_pos()
    if !_is_hovering(global_grabbed_item_pos):
        _fill_background(field_style, PriorityPanel.StylePriority.LOW)
        return

    _fill_background(field_style, PriorityPanel.StylePriority.LOW)

    var grabbed_item_coords := _ctrl_inventory_grid_basic.get_field_coords(global_grabbed_item_pos + (field_dimensions / 2))
    var item_size := inventory.get_item_size(grabbed_item)
    var rect := Rect2i(grabbed_item_coords, item_size)
    if !Rect2i(Vector2i.ZERO, inventory.size).encloses(rect):
        return
    _set_rect_background(rect, style, PriorityPanel.StylePriority.LOW)


func _is_hovering(local_pos: Vector2) -> bool:
    return get_rect().has_point(local_pos)


func _set_item_background(item: InventoryItem, style: StyleBox, priority: int) -> bool:
    if !item:
        return false

    _set_rect_background(inventory.get_item_rect(item), style, priority)
    return true


func _set_rect_background(rect: Rect2i, style: StyleBox, priority: int) -> void:
    var h_range = min(rect.size.x + rect.position.x, inventory.size.x)
    for i in range(rect.position.x, h_range):
        var v_range = min(rect.size.y + rect.position.y, inventory.size.y)
        for j in range(rect.position.y, v_range):
            _field_backgrounds[i][j].set_style(style, priority)


func _fill_background(style: StyleBox, priority: int) -> void:
    for panel in _field_background_grid.get_children():
        panel.set_style(style, priority)


func _get_global_grabbed_item() -> InventoryItem:
    if CtrlDragable.get_grabbed_dragable() == null:
        return null
    return (CtrlDragable.get_grabbed_dragable() as CtrlInventoryItemRect).item


func _get_global_grabbed_item_local_pos() -> Vector2:
    if CtrlDragable.get_grabbed_dragable():
        return get_local_mouse_position() - CtrlDragable.get_grab_offset_local_to(self)
    return Vector2(-1, -1)

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
    
