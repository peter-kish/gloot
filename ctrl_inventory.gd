class_name CtrlInventory
extends VBoxContainer
tool

export(NodePath) var inventory_path: NodePath setget _set_inventory_path;
export(Texture) var default_item_icon: Texture;
var inventory: Inventory = null setget _set_inventory;
var _item_list: ItemList;


func _get_configuration_warning() -> String:
    if inventory_path.is_empty():
        return "This node is not linked to an inventory, so it can't display any content.\n" + \
               "Set the inventory_path property to point to an Inventory node."
    return "";


func _set_inventory_path(new_inv_path: NodePath) -> void:
    inventory_path = new_inv_path;
    var node: Node = get_node_or_null(inventory_path);

    if is_inside_tree():
        assert(node is Inventory);
        
    _set_inventory(node);
    update_configuration_warning();


func _set_inventory(new_inventory: Inventory) -> void:
    if new_inventory == null && inventory:
        _disconnect_signals();

    inventory = new_inventory;

    if inventory:
        _refresh();
        _connect_signals();


func _ready():
    _item_list = ItemList.new();
    _item_list.size_flags_horizontal = SIZE_EXPAND_FILL;
    _item_list.size_flags_vertical = SIZE_EXPAND_FILL;
    add_child(_item_list);

    if has_node(inventory_path):
        _set_inventory(get_node(inventory_path));


func _connect_signals() -> void:
    inventory.connect("contents_changed", self, "_refresh");


func _disconnect_signals() -> void:
    inventory.disconnect("contents_changed", self, "_refresh");


func _refresh() -> void:
    _clear_list();
    _populate_list();


func _clear_list() -> void:
    if _item_list:
        _item_list.clear();


func _populate_list() -> void:
    if Engine.editor_hint:
        return;

    if inventory == null:
        return;

    for item in inventory.get_items():
        _item_list.add_item(_get_item_title(item), _get_item_texture(item));
        _item_list.set_item_metadata(_item_list.get_item_count() - 1, item);


func _get_item_title(item: InventoryItem) -> String:
    var title = item.get_property("name", item.prototype_id);
    if !(title is String):
        title = item.prototype_id;

    var stack_size: int = item.get_property(InventoryStacked.KEY_STACK_SIZE, \
            InventoryStacked.DEFAULT_STACK_SIZE);
    if stack_size > 1:
        title = "%s (x%d)" % [title, stack_size];

    return title;


func _get_item_texture(item: InventoryItem) -> Resource:
    var texture_path = item.get_property("image");\
    if texture_path:
        return load(texture_path);
    return default_item_icon;


func get_selected_inventory_items() -> Array:
    var result: Array = [];
    for index in _item_list.get_selected_items():
        result.push_back(_get_inventory_item(index));
    return result;


func _get_inventory_item(index: int) -> InventoryItem:
    assert(index >= 0);
    assert(index < _item_list.get_item_count());

    return _item_list.get_item_metadata(index);
