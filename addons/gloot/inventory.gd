extends Node
class_name Inventory
tool

signal item_added
signal item_removed
signal item_modified
signal contents_changed
signal protoset_changed

export(Resource) var item_protoset: Resource setget _set_item_protoset
var _items: Array = []

const KEY_NODE_NAME: String = "node_name"
const KEY_ITEM_PROTOSET: String = "item_protoset"
const KEY_ITEMS: String = "items"
const Verify = preload("res://addons/gloot/verify.gd")


func _get_configuration_warning() -> String:
    if item_protoset == null:
        return "This inventory node has no protoset. Set the 'item_protoset' field to be able to " \
        + "populate the inventory with items."
    return ""


func _set_item_protoset(new_item_protoset: Resource) -> void:
    assert((new_item_protoset is ItemProtoset) || (new_item_protoset == null), \
        "item_protoset must be an ItemProtoset resource!")
    
    item_protoset = new_item_protoset
    emit_signal("protoset_changed")
    update_configuration_warning()


static func _get_item_script() -> Script:
    return preload("inventory_item.gd")


func _enter_tree():
    for child in get_children():
        if child is InventoryItem:
            _items.append(child)


func _exit_tree():
    _items.clear()


func _ready() -> void:
    connect("item_added", self, "_on_item_added")
    connect("item_removed", self, "_on_item_removed")

    for item in get_items():
        _connect_item_signals(item)


func _on_item_added(item: InventoryItem) -> void:
    _items.append(item)
    emit_signal("contents_changed")
    _connect_item_signals(item)


func _on_item_removed(item: InventoryItem) -> void:
    _items.erase(item)
    emit_signal("contents_changed")
    _disconnect_item_signals(item)


func move_item(from: int, to: int) -> void:
    assert(from >= 0)
    assert(from < _items.size())
    assert(to >= 0)
    assert(to < _items.size())
    if from == to:
        return

    var item = _items[from]
    _items.remove(from)
    _items.insert(to, item)

    emit_signal("contents_changed")


func get_item_index(item: InventoryItem) -> int:
    return _items.find(item)


func get_item_count() -> int:
    return _items.size()


func _connect_item_signals(item: InventoryItem) -> void:
    if !item.is_connected("protoset_changed", self, "_emit_item_modified"):
        item.connect("protoset_changed", self, "_emit_item_modified", [item])
    if !item.is_connected("prototype_id_changed", self, "_emit_item_modified"):
        item.connect("prototype_id_changed", self, "_emit_item_modified", [item])
    if !item.is_connected("properties_changed", self, "_emit_item_modified"):
        item.connect("properties_changed", self, "_emit_item_modified", [item])


func _disconnect_item_signals(item:InventoryItem) -> void:
    if item.is_connected("protoset_changed", self, "_emit_item_modified"):
        item.disconnect("protoset_changed", self, "_emit_item_modified")
    if item.is_connected("prototype_id_changed", self, "_emit_item_modified"):
        item.disconnect("prototype_id_changed", self, "_emit_item_modified")
    if item.is_connected("properties_changed", self, "_emit_item_modified"):
        item.disconnect("properties_changed", self, "_emit_item_modified")


func _emit_item_modified(item: InventoryItem) -> void:
    emit_signal("item_modified", item)


func get_items() -> Array:
    return _items


func has_item(item: InventoryItem) -> bool:
    return item.get_parent() == self


func add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false

    if item.get_parent():
        item.get_parent().remove_child(item)

    add_child(item)
    if Engine.editor_hint:
        item.owner = get_tree().edited_scene_root
    return true


func create_and_add_item(prototype_id: String) -> InventoryItem:
    var item: InventoryItem = InventoryItem.new()
    item.prototype_id = prototype_id
    if add_item(item):
        return item
    else:
        item.free()
        return null


func remove_item(item: InventoryItem) -> bool:
    if item == null || !has_item(item):
        return false

    remove_child(item)
    return true


func remove_all_items() -> void:
    while get_child_count() > 0:
        remove_child(get_child(0))
    _items = []


func get_item_by_id(prototype_id: String) -> InventoryItem:
    for item in get_items():
        if item.prototype_id == prototype_id:
            return item
            
    return null


func has_item_by_id(prototype_id: String) -> bool:
    return get_item_by_id(prototype_id) != null


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    if remove_item(item):
        return destination.add_item(item)

    return false


func reset() -> void:
    clear()
    item_protoset = null


func clear() -> void:
    for item in get_items():
        item.queue_free()
    remove_all_items()


func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_NODE_NAME] = name
    result[KEY_ITEM_PROTOSET] = item_protoset.resource_path
    if !get_items().empty():
        result[KEY_ITEMS] = []
        for item in get_items():
            result[KEY_ITEMS].append(item.serialize())

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_ITEM_PROTOSET, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY):
        return false

    reset()

    name = source[KEY_NODE_NAME]
    item_protoset = load(source[KEY_ITEM_PROTOSET])
    if source.has(KEY_ITEMS):
        var items = source[KEY_ITEMS]
        for item_dict in items:
            var item = _get_item_script().new()
            item.deserialize(item_dict)
            assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.prototype_id)

    return true

