@tool
class_name CtrlInventory
extends Control

signal inventory_item_activated(item)

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        var node: Node = get_node_or_null(inventory_path)

        if node == null:
            return

        if is_inside_tree():
            assert(node is Inventory)
            
        self.inventory = node
        update_configuration_warnings()


@export var default_item_icon: Texture2D
var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        if new_inventory == inventory:
            return
    
        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()

        _refresh()
var _vbox_container: VBoxContainer
var _item_list: ItemList

const KEY_IMAGE = "image"
const KEY_NAME = "name"


func _get_configuration_warnings() -> PackedStringArray:
    if inventory_path.is_empty():
        return PackedStringArray([
                "This node is not linked to an inventory, so it can't display any content.\n" + \
                "Set the inventory_path property to point to an Inventory node."])
    return PackedStringArray()


func _ready():
    if Engine.is_editor_hint():
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
    _item_list.item_activated.connect(Callable(self, "_on_list_item_activated"))
    _vbox_container.add_child(_item_list)

    if has_node(inventory_path):
        self.inventory = get_node(inventory_path)

    _refresh()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    if !inventory.contents_changed.is_connected(Callable(self, "_refresh")):
        inventory.contents_changed.connect(Callable(self, "_refresh"))
    if !inventory.item_modified.is_connected(Callable(self, "_on_item_modified")):
        inventory.item_modified.connect(Callable(self, "_on_item_modified"))


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    if inventory.contents_changed.is_connected(Callable(self, "_refresh")):
        inventory.contents_changed.disconnect(Callable(self, "_refresh"))
    if inventory.item_modified.is_connected(Callable(self, "_on_item_modified")):
        inventory.item_modified.disconnect(Callable(self, "_on_item_modified"))


func _on_list_item_activated(index: int) -> void:
    inventory_item_activated.emit(_get_inventory_item(index))


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
        var texture := item.get_texture()
        if !texture:
            texture = default_item_icon
        _item_list.add_item(_get_item_title(item), texture)
        _item_list.set_item_metadata(_item_list.get_item_count() - 1, item)


func _get_item_title(item: InventoryItem) -> String:
    if item == null:
        return ""

    var title = item.get_title()
    var stack_size: int = InventoryStacked.get_item_stack_size(item)
    if stack_size > 1:
        title = "%s (x%d)" % [title, stack_size]

    return title


func get_selected_inventory_item() -> InventoryItem:
    if _item_list.get_selected_items().is_empty():
        return null

    return _get_inventory_item(_item_list.get_selected_items()[0])


func _get_inventory_item(index: int) -> InventoryItem:
    assert(index >= 0)
    assert(index < _item_list.get_item_count())

    return _item_list.get_item_metadata(index)


func deselect_inventory_item() -> void:
    _item_list.deselect_all()


func select_inventory_item(item: InventoryItem) -> void:
    _item_list.deselect_all()
    for index in _item_list.item_count:
        if _item_list.get_item_metadata(index) != item:
            continue
        _item_list.select(index)
        return

