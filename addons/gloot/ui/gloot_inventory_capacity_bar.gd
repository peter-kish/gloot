@tool
extends Panel

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        inventory = get_node_or_null(inventory_path)

var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        if inventory == new_inventory:
            return

        if inventory != null:
            _disconnect_inventory_signals()
        inventory = new_inventory
        _refresh()
        if inventory != null:
            _connect_inventory_signals()

@export var background_style: StyleBox :
    get:
        return background_style
    set(new_background_style):
        if new_background_style == background_style:
            return
        background_style = new_background_style
        _set_panel_style(self, background_style)
        
@export var bar_style: StyleBox :
    get:
        return bar_style
    set(new_bar_style):
        if new_bar_style == bar_style:
            return
        bar_style = new_bar_style
        _set_panel_style(_bar_panel, bar_style)

var _bar_panel: Panel = null


func _connect_inventory_signals() -> void:
    if !inventory.is_node_ready():
        inventory.ready.connect(_refresh)
    inventory.contents_changed.connect(_refresh)
    inventory.protoset_changed.connect(_refresh)
    if inventory.get_weight_constraint():
        inventory.get_weight_constraint().capacity_changed.connect(_refresh)
        inventory.get_weight_constraint().occupied_space_changed.connect(_refresh)


func _disconnect_inventory_signals() -> void:
    if inventory.ready.is_connected(_refresh):
        inventory.ready.disconnect(_refresh)
    inventory.contents_changed.disconnect(_refresh)
    inventory.protoset_changed.disconnect(_refresh)
    if inventory.get_weight_constraint():
        inventory.get_weight_constraint().capacity_changed.disconnect(_refresh)
        inventory.get_weight_constraint().occupied_space_changed.disconnect(_refresh)


func _refresh() -> void:
    if _bar_panel == null:
        return
    _bar_panel.size.x = 0
    _bar_panel.size.y = size.y

    if inventory == null || !inventory.is_node_ready():
        return

    var weight_constraint := inventory.get_weight_constraint()
    if weight_constraint == null:
        return

    if !weight_constraint.has_unlimited_capacity():
        _bar_panel.size.x = size.x * (weight_constraint.occupied_space / weight_constraint.capacity)


func _ready() -> void:
    if !inventory_path.is_empty():
        inventory = get_node_or_null(inventory_path)

    _set_panel_style(self, background_style)

    _bar_panel = Panel.new()
    _set_panel_style(_bar_panel, bar_style)
    add_child(_bar_panel)

    resized.connect(_refresh)

    _refresh()


func _set_panel_style(panel: Panel, style: StyleBox) -> void:
    if panel == null:
        return
    panel.remove_theme_stylebox_override("panel")
    if style != null:
        panel.add_theme_stylebox_override("panel", style)

