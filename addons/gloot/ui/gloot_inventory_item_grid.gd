@tool
extends Control

# TODO: Consider renaming to item_activated
signal inventory_item_activated(item)
signal inventory_item_context_activated(item)

const GlootInventoryFieldGrid = preload("res://addons/gloot/ui/gloot_inventory_field_grid.gd")
const GlootInventoryItemRect = preload("res://addons/gloot/ui/gloot_inventory_item_rect.gd")

@export var inventory: Inventory = null :
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

@export var field_grid: GlootInventoryFieldGrid = null :
    set(new_field_grid):
        if field_grid == new_field_grid:
            return

        if new_field_grid == null:
            field_grid.sort_children.disconnect(_update_item_rects)
            field_grid = null
            _clear()
            return

        field_grid = new_field_grid
        field_grid.sort_children.connect(_update_item_rects)
        _refresh()


@export var selection_style: StyleBox :
    set(new_selection_style):
        selection_style = new_selection_style
        for gloot_inventory_item_rect in get_children():
            gloot_inventory_item_rect.selection_style = selection_style


var _selected_item_rect: GlootInventoryItemRect = null


func _connect_inventory_signals() -> void:
    if !inventory.is_node_ready():
        inventory.ready.connect(_refresh)
    inventory.contents_changed.connect(_refresh)
    inventory.prototree_json_changed.connect(_refresh)
    inventory.item_prototree_changed.connect(_refresh_item)
    inventory.item_prototype_path_changed.connect(_refresh_item)
    inventory.item_property_changed.connect(_on_item_property_changed)
    if inventory.get_grid_constraint() != null:
        inventory.get_grid_constraint().item_moved.connect(_refresh_item)
        inventory.get_grid_constraint().size_changed.connect(_refresh)


func _disconnect_inventory_signals() -> void:
    if inventory.ready.is_connected(_refresh):
        inventory.ready.disconnect(_refresh)
    inventory.contents_changed.disconnect(_refresh)
    inventory.prototree_json_changed.disconnect(_refresh)
    inventory.item_prototree_changed.disconnect(_refresh_item)
    inventory.item_prototype_path_changed.disconnect(_refresh_item)
    inventory.item_property_changed.disconnect(_on_item_property_changed)
    if inventory.get_grid_constraint() != null:
        inventory.get_grid_constraint().item_moved.disconnect(_refresh_item)
        inventory.get_grid_constraint().size_changed.disconnect(_refresh)


func _refresh_item(item: InventoryItem) -> void:
    var index := inventory.get_item_index(item)
    if get_child_count() <= index:
        return
    get_children()[index].refresh(_get_item_ui_rect(item))


func _on_item_property_changed(item: InventoryItem, property_: String) -> void:
    _refresh_item(item)


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _refresh()

        
func _refresh() -> void:
    var selected_item := _selected_item()
    _clear()
    _populate(selected_item)


func _selected_item() -> InventoryItem:
    if inventory == null:
        return null
    if _selected_item_rect == null:
        return null
    if !is_instance_valid(_selected_item_rect.item):
        return null

    return _selected_item_rect.item


func _clear() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    custom_minimum_size = Vector2.ZERO


func _populate(selected_item: InventoryItem) -> void:
    if inventory == null || !inventory.is_node_ready() || field_grid == null:
        return

    if inventory.get_grid_constraint() == null:
        return

    for item in inventory.get_items():
        var item_rect = _get_item_ui_rect(item)
        var gloot_inventory_item_rect := GlootInventoryItemRect.new(item, item_rect)
        gloot_inventory_item_rect.selection_style = selection_style
        gloot_inventory_item_rect.selected_status_changed.connect(_on_selected_status_changed.bind(gloot_inventory_item_rect))
        gloot_inventory_item_rect.activated.connect(func(): inventory_item_activated.emit(item))
        gloot_inventory_item_rect.context_activated.connect(func(): inventory_item_context_activated.emit(item))
        gloot_inventory_item_rect.selected = (item == selected_item)

        add_child(gloot_inventory_item_rect)

    custom_minimum_size = field_grid.size


func _on_selected_status_changed(gloot_inventory_item_rect: GlootInventoryItemRect) -> void:
    if gloot_inventory_item_rect.selected && (_selected_item_rect != null):
        _selected_item_rect.selected = false
    _selected_item_rect = gloot_inventory_item_rect


func get_selected_item() -> InventoryItem:
    if _selected_item_rect == null:
        return null
    return _selected_item_rect.item


func _update_item_rects() -> void:
    if inventory == null || !inventory.is_node_ready() || field_grid == null:
        return

    assert(inventory.get_item_count() == get_child_count())
    for item_index in range(inventory.get_items().size()):
        var item = inventory.get_items()[item_index]
        var item_rect = _get_item_ui_rect(item)
        var texture_rect = get_child(item_index)
        texture_rect.position = item_rect.position
        texture_rect.size = item_rect.size

    custom_minimum_size = field_grid.size


func _get_item_ui_rect(item: InventoryItem) -> Rect2:
    var grid_constraint := inventory.get_grid_constraint()
    
    var item_field_rect := grid_constraint.get_item_rect(item)
    var top_left := field_grid.get_field_position(item_field_rect.position)
    var bottom_right := field_grid.get_field_position(item_field_rect.position + item_field_rect.size - Vector2i.ONE)
    bottom_right += field_grid.field_size

    return Rect2(top_left, bottom_right - top_left)
