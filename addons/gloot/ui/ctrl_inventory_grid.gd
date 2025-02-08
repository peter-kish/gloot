@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_grid.svg")
class_name CtrlInventoryGrid
extends Control
## Control node for displaying inventories with a GridConstraint.
##
## Displays the inventory contents on a 2D grid. The grid style, size and item icons are customizable.

signal item_dropped(item: InventoryItem, offset: Vector2) ## Emitted when an item has been dropped onto the 2D grid.
signal selection_changed ## Emitted when the item selection has changed.
signal inventory_item_activated(item: InventoryItem) ## Emitted when an inventory item has been double-clicked.
signal inventory_item_clicked(item: InventoryItem) ## Emitted when an inventory item has been right-clicked.
signal inventory_item_selected(item: InventoryItem) ## Emitted when an inventory item has been selected.
signal item_mouse_entered(item: InventoryItem) ## Emitted when the mouse cursor has entered the visible area of an item.
signal item_mouse_exited(item: InventoryItem) ## Emitted when the mouse cursor has exited the visible area of an item.

const _Verify = preload("res://addons/gloot/core/verify.gd")
const _CtrlInventoryGridBasic = preload("res://addons/gloot/ui/ctrl_inventory_grid_basic.gd")
const _CtrlDraggableInventoryItem = preload("res://addons/gloot/ui/ctrl_draggable_inventory_item.gd")
const _Utils = preload("res://addons/gloot/core/utils.gd")


class PriorityPanel extends Panel:
    enum StylePriority {HIGH = 0, MEDIUM = 1, LOW = 2}

    var regular_style: StyleBox
    var hover_style: StyleBox
    var _styles: Array[StyleBox] = [null, null, null]


    func _init(regular_style_: StyleBox = null, hover_style_: StyleBox = null) -> void:
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


class CustomizablePanel extends Panel:
    func set_style(style: StyleBox) -> void:
        remove_theme_stylebox_override("panel")
        if style != null:
            add_theme_stylebox_override("panel", style)

## Reference to an inventory with a GridConstraint that is being displayed.
@export var inventory: Inventory = null:
    set(new_inventory):
        if inventory == new_inventory:
            return

        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()

        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.inventory = inventory
        _queue_refresh()
        update_configuration_warnings()
## If enabled, stretches the icons based on `field_dimensions`.
@export var stretch_item_icons: bool = true:
    set(new_stretch_item_icons):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.stretch_item_icons = new_stretch_item_icons
        stretch_item_icons = new_stretch_item_icons
## Size of individual fields in the grid.
@export var field_dimensions: Vector2 = Vector2(32, 32):
    set(new_field_dimensions):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.field_dimensions = new_field_dimensions
        field_dimensions = new_field_dimensions
        _queue_refresh()
## Spacing between grid fields.
@export var item_spacing: int = 0:
    set(new_item_spacing):
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.item_spacing = new_item_spacing
        item_spacing = new_item_spacing
        _queue_refresh()
## Item selection mode. Set to SelectMode.SELECT_MULTI to enable selecting multiple items by holding down CTRL. See the
## `ItemList.SelectMode` constants for details.
@export_enum("Single", "Multi") var select_mode: int = ItemList.SelectMode.SELECT_SINGLE:
    set(new_select_mode):
        if select_mode == new_select_mode:
            return
        select_mode = new_select_mode
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.select_mode = select_mode
## Custom control scene representing an `InventoryItem` (must inherit `CtrlInventoryItemBase`). If set to `null`,
## `CtrlInventoryItem` will be used to represent the item.
@export var custom_item_control_scene: PackedScene = null:
    set(new_custom_item_control_scene):
        if new_custom_item_control_scene == custom_item_control_scene:
            return
        if !_valid_custom_item_control_scene(new_custom_item_control_scene):
            push_error("Invalid scene! Make sure the custom item control scene inherits from CtrlInventoryItemBase!")
            return
        custom_item_control_scene = new_custom_item_control_scene
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.custom_item_control_scene = custom_item_control_scene
## Multiplies the color of the item's texture when dragging.
@export var drag_tint := Color.WHITE:
    set(new_drag_tint):
        if new_drag_tint == drag_tint:
            return
        drag_tint = new_drag_tint
        if is_instance_valid(_ctrl_inventory_grid_basic):
            _ctrl_inventory_grid_basic.drag_tint = drag_tint


@export_group("Custom Styles")
## The default grid field background style. Unlike `background_style`, this style is used when displaying each
## individual field in the 2D grid.
@export var field_style: StyleBox = null:
    set(new_field_style):
        field_style = new_field_style
        _queue_refresh()
## The grid field style used when hovering over it with the mouse.
@export var field_highlighted_style: StyleBox:
    set(new_field_highlighted_style):
        field_highlighted_style = new_field_highlighted_style
        _queue_refresh()
## The grid field style used for selected items. Unlike `selection_style`, this style is used as field background behind
## selected items.
@export var field_selected_style: StyleBox:
    set(new_field_selected_style):
        field_selected_style = new_field_selected_style
        _queue_refresh()
## The style used for displaying item selections. Unlike `field_selected_style`, this style is used when displaying
## rectangles over the selected items.
@export var selection_style: StyleBox = null:
    set(new_selection_style):
        selection_style = new_selection_style
        _queue_refresh()
## The style used for the inventory background. Unlike `field_style`, this style is used when displaying a rectangle
## behind the 2D grid.
@export var background_style: StyleBox = null:
    set(new_background_style):
        background_style = new_background_style
        _queue_refresh()

var _ctrl_inventory_grid_basic: _CtrlInventoryGridBasic = null
var _field_background_grid: Control = null
var _field_backgrounds: Array = []
var _selection_panels: Control = null
var _refresh_queued: bool = false
var _background: CustomizablePanel = null


func _valid_custom_item_control_scene(scene: PackedScene) -> bool:
    if scene == null:
        return true
    if !scene.can_instantiate():
        return false
    var temp_instance := scene.instantiate()
    if !temp_instance is CtrlInventoryItemBase:
        temp_instance.free()
        return false
    temp_instance.free()
    return true


func _get_field_style() -> StyleBox:
    if field_style:
        return field_style
    return preload("res://addons/gloot/ui/ctrl_inventory_grid_field_style_normal.tres")


func _get_selection_style() -> StyleBox:
    if selection_style:
        return selection_style
    return preload("res://addons/gloot/ui/ctrl_inventory_grid_style_selection.tres")


func _get_background_style() -> StyleBox:
    if background_style:
        return background_style
    return preload("res://addons/gloot/ui/ctrl_inventory_grid_style_background.tres")


func _get_field_highlighted_style() -> StyleBox:
    return field_highlighted_style


func _get_field_selected_style() -> StyleBox:
    return field_selected_style


func _get_configuration_warnings() -> PackedStringArray:
    if !is_instance_valid(inventory):
        return PackedStringArray([
                "This CtrlInventoryGrid node has no inventory set. Set the 'inventory' field to be able to " \
                + "display its contents."])
    if inventory.get_constraint(GridConstraint) == null:
        return PackedStringArray([
                "The inventory has no GridConstraint child node. Add a GridConstraint to the inventory to be able" \
                + " to display its contents on a grid."])
    return PackedStringArray()


func _connect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return
    inventory.constraint_changed.connect(_on_constraint_changed)
    inventory.constraint_added.connect(_on_constraint_changed)
    inventory.constraint_removed.connect(_on_constraint_changed)
    inventory.item_property_changed.connect(_on_item_property_changed)
    inventory.item_added.connect(_on_item_manipulated)
    inventory.item_removed.connect(_on_item_manipulated)


func _disconnect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return
    inventory.constraint_changed.disconnect(_on_constraint_changed)
    inventory.constraint_added.disconnect(_on_constraint_changed)
    inventory.constraint_removed.disconnect(_on_constraint_changed)
    inventory.item_property_changed.disconnect(_on_item_property_changed)
    inventory.item_added.disconnect(_on_item_manipulated)
    inventory.item_removed.disconnect(_on_item_manipulated)


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
    if constraint is GridConstraint:
        _queue_refresh()


func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    var relevant_properties := [
        GridConstraint._KEY_SIZE,
        GridConstraint._KEY_ROTATED,
    ]
    if property in relevant_properties:
        _queue_refresh()


func _on_item_manipulated(item: InventoryItem) -> void:
    _queue_refresh()


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
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return
    if !is_instance_valid(_selection_panels):
        return

    for child in _selection_panels.get_children():
        child.queue_free()

    var selected_items := _ctrl_inventory_grid_basic.get_selected_inventory_items()
    _selection_panels.visible = (!selected_items.is_empty()) && (_get_selection_style() != null)
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        var selection_panel := CustomizablePanel.new()
        var rect := _ctrl_inventory_grid_basic.get_item_rect(selected_item)
        selection_panel.position = rect.position
        selection_panel.size = rect.size
        selection_panel.set_style(_get_selection_style())
        selection_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _selection_panels.add_child(selection_panel)


func _refresh_field_background_grid() -> void:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return
    if is_instance_valid(_field_background_grid):
        while _field_background_grid.get_child_count() > 0:
            _field_background_grid.get_children()[0].queue_free()
            _field_background_grid.remove_child(_field_background_grid.get_children()[0])
    _field_backgrounds = []

    if !is_instance_valid(inventory):
        return
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    if grid_constraint == null:
        return

    var inv_size := grid_constraint.size
    for i in range(inv_size.x):
        _field_backgrounds.append([])
        for j in range(inv_size.y):
            var field_panel: PriorityPanel = PriorityPanel.new(_get_field_style(), _get_field_highlighted_style())
            field_panel.size = field_dimensions
            field_panel.position = _ctrl_inventory_grid_basic._get_field_position(Vector2i(i, j))
            _field_background_grid.add_child(field_panel)
            _field_backgrounds[i].append(field_panel)


func _ready() -> void:
    _background = CustomizablePanel.new()
    _background.name = "Background"
    _background.set_style(_get_background_style())
    add_child(_background)

    _field_background_grid = Control.new()
    _field_background_grid.name = "FieldBackgrounds"
    add_child(_field_background_grid)

    _ctrl_inventory_grid_basic = _CtrlInventoryGridBasic.new()
    _ctrl_inventory_grid_basic.custom_item_control_scene = custom_item_control_scene
    _ctrl_inventory_grid_basic.drag_tint = drag_tint
    _ctrl_inventory_grid_basic.inventory = inventory
    _ctrl_inventory_grid_basic.field_dimensions = field_dimensions
    _ctrl_inventory_grid_basic.item_spacing = item_spacing
    _ctrl_inventory_grid_basic.stretch_item_icons = stretch_item_icons
    _ctrl_inventory_grid_basic.name = "_CtrlInventoryGridBasic"
    _ctrl_inventory_grid_basic.resized.connect(_update_size)
    _ctrl_inventory_grid_basic.item_dropped.connect(func(item: InventoryItem, drop_position: Vector2):
        item_dropped.emit(item, drop_position)
    )
    _ctrl_inventory_grid_basic.inventory_item_activated.connect(func(item: InventoryItem):
        inventory_item_activated.emit(item)
    )
    _ctrl_inventory_grid_basic.inventory_item_clicked.connect(func(item: InventoryItem, at_position: Vector2, mouse_button_index: int):
        inventory_item_clicked.emit(item, at_position, mouse_button_index)
    )
    _ctrl_inventory_grid_basic.inventory_item_selected.connect(func(item: InventoryItem):
        inventory_item_selected.emit(item)
    )
    _ctrl_inventory_grid_basic.item_mouse_entered.connect(_on_item_mouse_entered)
    _ctrl_inventory_grid_basic.item_mouse_exited.connect(_on_item_mouse_exited)
    _ctrl_inventory_grid_basic.selection_changed.connect(_on_selection_changed)
    _ctrl_inventory_grid_basic.select_mode = select_mode
    _ctrl_inventory_grid_basic.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_ctrl_inventory_grid_basic)

    _selection_panels = Control.new()
    _selection_panels.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _selection_panels.name = "SelectionPanels"
    add_child(_selection_panels)

    _update_size()
    _queue_refresh()


func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_BEGIN:
        _ctrl_inventory_grid_basic.mouse_filter = Control.MOUSE_FILTER_PASS
    if what == NOTIFICATION_DRAG_END:
        _ctrl_inventory_grid_basic.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _fill_background(_get_field_style(), PriorityPanel.StylePriority.LOW)


func _update_size() -> void:
    custom_minimum_size = _ctrl_inventory_grid_basic.size
    size = _ctrl_inventory_grid_basic.size
    _background.size = _ctrl_inventory_grid_basic.size


func _on_item_mouse_entered(item: InventoryItem) -> void:
    _set_item_background(item, _get_field_highlighted_style(), PriorityPanel.StylePriority.MEDIUM)
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

    if !_get_field_selected_style():
        return
    for item in inventory.get_items():
        if item in _ctrl_inventory_grid_basic.get_selected_inventory_items():
            _set_item_background(item, _get_field_selected_style(), PriorityPanel.StylePriority.HIGH)
        else:
            _set_item_background(item, null, PriorityPanel.StylePriority.HIGH)


func _on_inventory_resized() -> void:
    _refresh_field_background_grid()


func _input(event) -> void:
    if !(event is InputEventMouseMotion):
        return
    if !is_instance_valid(inventory):
        return
    
    if !_get_field_highlighted_style():
        return
    _highlight_grabbed_item(_get_field_highlighted_style())


func _highlight_grabbed_item(style: StyleBox):
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    if grid_constraint == null:
        return
    var grabbed_item: InventoryItem = _get_global_grabbed_item()
    if !grabbed_item:
        return

    var global_grabbed_item_pos: Vector2 = _get_global_grabbed_item_local_pos()
    if !_is_hovering(global_grabbed_item_pos):
        _fill_background(_get_field_style(), PriorityPanel.StylePriority.LOW)
        return

    _fill_background(_get_field_style(), PriorityPanel.StylePriority.LOW)

    var grabbed_item_coords := _ctrl_inventory_grid_basic.get_field_coords(global_grabbed_item_pos + (field_dimensions / 2))
    var item_size := grid_constraint.get_item_size(grabbed_item)
    var rect := Rect2i(grabbed_item_coords, item_size)
    if !Rect2i(Vector2i.ZERO, grid_constraint.size).encloses(rect):
        return
    _set_rect_background(rect, style, PriorityPanel.StylePriority.LOW)


func _is_hovering(local_pos: Vector2) -> bool:
    return get_rect().has_point(local_pos)


func _set_item_background(item: InventoryItem, style: StyleBox, priority: int) -> bool:
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    if !item || grid_constraint == null:
        return false

    _set_rect_background(grid_constraint.get_item_rect(item), style, priority)
    return true


func _set_rect_background(rect: Rect2i, style: StyleBox, priority: int) -> void:
    var grid_constraint: GridConstraint = inventory.get_constraint(GridConstraint)
    var inv_size = grid_constraint.size
    var h_range = min(rect.size.x + rect.position.x, inv_size.x)
    for i in range(rect.position.x, h_range):
        var v_range = min(rect.size.y + rect.position.y, inv_size.y)
        for j in range(rect.position.y, v_range):
            _field_backgrounds[i][j].set_style(style, priority)


func _fill_background(style: StyleBox, priority: int) -> void:
    for panel in _field_background_grid.get_children():
        panel.set_style(style, priority)


func _get_global_grabbed_item() -> InventoryItem:
    var drag_data := get_viewport().gui_get_drag_data()
    if !is_instance_valid(drag_data):
        return null
    if !(drag_data is InventoryItem):
        return null
    return drag_data as InventoryItem


func _get_global_grabbed_item_local_pos() -> Vector2:
    if _get_global_grabbed_item() != null:
        return get_local_mouse_position() - _CtrlDraggableInventoryItem.get_grab_offset_local_to(self)
    return Vector2(-1, -1)


## Deselects all selected inventory items.
func deselect_inventory_items() -> void:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return
    _ctrl_inventory_grid_basic.deselect_inventory_items()


## Selects the given inventory item.
func select_inventory_item(item: InventoryItem) -> void:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return
    _ctrl_inventory_grid_basic.select_inventory_item(item)


## Returns the selected inventory item. If multiple items are selected, it returns the first one.
func get_selected_inventory_item() -> InventoryItem:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return null
    return _ctrl_inventory_grid_basic.get_selected_inventory_item()


## Returns an array of selected inventory items.
func get_selected_inventory_items() -> Array[InventoryItem]:
    if !is_instance_valid(_ctrl_inventory_grid_basic):
        return []
    return _ctrl_inventory_grid_basic.get_selected_inventory_items()
