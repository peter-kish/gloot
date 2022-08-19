class_name CtrlInventory
extends Control
tool

signal inventory_item_activated

export(NodePath) var inventory_path: NodePath setget _set_inventory_path
export(Texture) var default_item_icon: Texture
var inventory: Inventory = null setget _set_inventory
var _vbox_container: VBoxContainer
var _item_list: ItemList

const KEY_IMAGE = "image"
const KEY_NAME = "name"


func _get_configuration_warning() -> String:
    if inventory_path.is_empty():
        return "This node is not linked to an inventory, so it can't display any content.\n" + \
               "Set the inventory_path property to point to an Inventory node."
    return ""


func _set_inventory_path(new_inv_path: NodePath) -> void:
    inventory_path = new_inv_path
    var node: Node = get_node_or_null(inventory_path)

    if is_inside_tree() && node:
        assert(node is Inventory)
        
    _set_inventory(node)
    update_configuration_warning()


func _set_inventory(new_inventory: Inventory) -> void:
    if new_inventory == inventory:
        return
  
    _disconnect_inventory_signals()
    inventory = new_inventory
    _connect_inventory_signals()

    _refresh()


func _ready():
    if Engine.editor_hint:
        # Clean up, in case it is duplicated in the editor
        if _vbox_container:
            _vbox_container.queue_free()

    _vbox_container = VBoxContainer.new()
    _vbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _vbox_container.size_flags_vertical = SIZE_EXPAND_FILL
    _vbox_container.anchor_right = 1.0
    _vbox_container.anchor_bottom = 1.0
    add_child(_vbox_container)

    _item_list = ItemList.new()
    _item_list.size_flags_horizontal = SIZE_EXPAND_FILL
    _item_list.size_flags_vertical = SIZE_EXPAND_FILL
    _item_list.connect("item_activated", self, "_on_list_item_activated")
    _vbox_container.add_child(_item_list)

    if has_node(inventory_path):
        _set_inventory(get_node(inventory_path))

    _refresh()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    if !inventory.is_connected("contents_changed", self, "_refresh"):
        inventory.connect("contents_changed", self, "_refresh")
    if !inventory.is_connected("item_modified", self, "_on_item_modified"):
        inventory.connect("item_modified", self, "_on_item_modified")


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.is_connected("contents_changed", self, "_refresh"):
        inventory.disconnect("contents_changed", self, "_refresh")
    if inventory.is_connected("item_modified", self, "_on_item_modified"):
        inventory.disconnect("item_modified", self, "_on_item_modified")


func _on_list_item_activated(index: int) -> void:
    emit_signal("inventory_item_activated", _get_inventory_item(index))


func _on_item_modified(_item: InventoryItem) -> void:
    _refresh()


func _refresh() -> void:
    if is_inside_tree():
        _clear_list()
        _populate_list()


func _clear_list() -> void:
    if _item_list:
        _item_list.clear()


func _populate_list() -> void:
    if inventory == null:
        return

    for item in inventory.get_items():
        _item_list.add_item(_get_item_title(item), item.get_texture())
        _item_list.set_item_metadata(_item_list.get_item_count() - 1, item)


func _get_item_title(item: InventoryItem) -> String:
    if item == null:
        return ""

    var title = item.get_title()
    var stack_size: int = item.get_property(InventoryStacked.KEY_STACK_SIZE, \
            InventoryStacked.DEFAULT_STACK_SIZE)
    if stack_size > 1:
        title = "%s (x%d)" % [title, stack_size]

    return title


func get_selected_inventory_items() -> Array:
    var result: Array = []
    for index in _item_list.get_selected_items():
        result.push_back(_get_inventory_item(index))
    return result


func _get_inventory_item(index: int) -> InventoryItem:
    assert(index >= 0)
    assert(index < _item_list.get_item_count())

    return _item_list.get_item_metadata(index)
