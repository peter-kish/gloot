@tool
class_name GlootInventory
extends ItemList

signal inventory_item_activated(item)
signal inventory_item_context_activated(item)

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")

@export var inventory: Inventory = null :
    get:
        return inventory
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


func _connect_inventory_signals() -> void:
    if !inventory.is_node_ready():
        inventory.ready.connect(_refresh)
    inventory.contents_changed.connect(_refresh)
    inventory.protoset_changed.connect(_refresh)
    inventory.item_property_changed.connect(_on_item_property_changed)
    inventory.item_protoset_changed.connect(_refresh_item)
    inventory.item_prototype_id_changed.connect(_refresh_item)


func _disconnect_inventory_signals() -> void:
    if inventory.ready.is_connected(_refresh):
        inventory.ready.disconnect(_refresh)
    inventory.contents_changed.disconnect(_refresh)
    inventory.protoset_changed.disconnect(_refresh)
    inventory.item_property_changed.disconnect(_on_item_property_changed)
    inventory.item_protoset_changed.disconnect(_refresh_item)
    inventory.item_prototype_id_changed.disconnect(_refresh_item)


func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    if property == InventoryItem.KEY_NAME || property == StacksConstraint.KEY_STACK_SIZE:
        set_item_text(inventory.get_item_index(item), _get_item_title(item))
    if property == InventoryItem.KEY_IMAGE:
        set_item_icon(inventory.get_item_index(item), item.get_texture())


func _ready() -> void:
    item_activated.connect(_on_list_item_activated)
    item_clicked.connect(_on_list_item_clicked)
    _refresh()


func _on_list_item_activated(index: int) -> void:
    inventory_item_activated.emit(_get_inventory_item(index))


func _on_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
    if mouse_button_index == MOUSE_BUTTON_RIGHT:
        inventory_item_context_activated.emit(_get_inventory_item(index))


func get_selected_inventory_item() -> InventoryItem:
    if get_selected_items().is_empty():
        return null

    return _get_inventory_item(get_selected_items()[0])


func _get_inventory_item(index: int) -> InventoryItem:
    assert(index >= 0)
    assert(index < get_item_count())
    return get_item_metadata(index)


func _refresh_item(item: InventoryItem) -> void:
    var item_index := inventory.get_item_index(item)
    set_item_text(item_index, _get_item_title(item))
    set_item_icon(item_index, item.get_texture())


func _refresh() -> void:
    _clear()
    _populate()


func _clear() -> void:
    clear()


func _populate() -> void:
    if inventory == null:
        return

    for item in inventory.get_items():
        var texture := item.get_texture()
        add_item(_get_item_title(item), texture)
        set_item_metadata(get_item_count() - 1, item)


func _get_item_title(item: InventoryItem) -> String:
    if item == null:
        return ""

    var title = item.get_title()
    var stack_size: int = InventoryStacked.get_item_stack_size(item)
    if stack_size > 1:
        title = "%s (x%d)" % [title, stack_size]

    return title


func deselect_inventory_item() -> void:
    deselect_all()


func select_inventory_item(item: InventoryItem) -> void:
    deselect_all()
    for index in item_count:
        if get_item_metadata(index) != item:
            continue
        select(index)
        return
