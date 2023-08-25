@tool
extends Node
class_name Inventory

signal item_added(item)
signal item_removed(item)
signal item_modified(item)
signal contents_changed
signal protoset_changed

const ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")

@export var item_protoset: ItemProtoset:
    get:
        return item_protoset
    set(new_item_protoset):
        if new_item_protoset == item_protoset:
            return
        if not _items.is_empty():
            return
        item_protoset = new_item_protoset
        protoset_changed.emit()
        update_configuration_warnings()
var _items: Array[InventoryItem] = []
var _constraint_manager: ConstraintManager = null

const KEY_NODE_NAME: String = "node_name"
const KEY_ITEM_PROTOSET: String = "item_protoset"
const KEY_CONSTRAINTS: String = "constraints"
const KEY_ITEMS: String = "items"
const Verify = preload("res://addons/gloot/core/verify.gd")


func _get_configuration_warnings() -> PackedStringArray:
    if item_protoset == null:
        return PackedStringArray([
                "This inventory node has no protoset. Set the 'item_protoset' field to be able to " \
                + "populate the inventory with items."])
    return PackedStringArray()


static func _get_item_script() -> Script:
    return preload("inventory_item.gd")


func _enter_tree():
    for child in get_children():
        if not child is InventoryItem:
            continue
        if has_item(child):
            continue
        _items.append(child)


func _exit_tree():
    _items.clear()


func _init() -> void:
    _constraint_manager = ConstraintManager.new(self)


func _ready() -> void:
    for item in get_items():
        _connect_item_signals(item)


func _on_item_added(item: InventoryItem) -> void:
    _items.append(item)
    contents_changed.emit()
    _connect_item_signals(item)
    _constraint_manager._on_item_added(item)
    item_added.emit(item)


func _on_item_removed(item: InventoryItem) -> void:
    _items.erase(item)
    contents_changed.emit()
    _disconnect_item_signals(item)
    _constraint_manager._on_item_removed(item)
    item_removed.emit(item)


func move_item(from: int, to: int) -> void:
    assert(from >= 0)
    assert(from < _items.size())
    assert(to >= 0)
    assert(to < _items.size())
    if from == to:
        return

    var item = _items[from]
    _items.remove_at(from)
    _items.insert(to, item)

    contents_changed.emit()


func get_item_index(item: InventoryItem) -> int:
    return _items.find(item)


func get_item_count() -> int:
    return _items.size()


func _connect_item_signals(item: InventoryItem) -> void:
    if !item.protoset_changed.is_connected(Callable(self, "_emit_item_modified")):
        item.protoset_changed.connect(Callable(self, "_emit_item_modified").bind(item))
    if !item.prototype_id_changed.is_connected(Callable(self, "_emit_item_modified")):
        item.prototype_id_changed.connect(Callable(self, "_emit_item_modified").bind(item))
    if !item.properties_changed.is_connected(Callable(self, "_emit_item_modified")):
        item.properties_changed.connect(Callable(self, "_emit_item_modified").bind(item))


func _disconnect_item_signals(item:InventoryItem) -> void:
    if item.protoset_changed.is_connected(Callable(self, "_emit_item_modified")):
        item.protoset_changed.disconnect(Callable(self, "_emit_item_modified"))
    if item.prototype_id_changed.is_connected(Callable(self, "_emit_item_modified")):
        item.prototype_id_changed.disconnect(Callable(self, "_emit_item_modified"))
    if item.properties_changed.is_connected(Callable(self, "_emit_item_modified")):
        item.properties_changed.disconnect(Callable(self, "_emit_item_modified"))


func _emit_item_modified(item: InventoryItem) -> void:
    _constraint_manager._on_item_modified(item)
    item_modified.emit(item)


func get_items() -> Array[InventoryItem]:
    return _items


func has_item(item: InventoryItem) -> bool:
    return item in _items


func add_item(item: InventoryItem) -> bool:
    if !can_add_item(item):
        return false

    if item.get_parent():
        item.get_parent().remove_child(item)

    add_child(item)
    if Engine.is_editor_hint():
        item.owner = get_tree().edited_scene_root
    return true


func can_add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false
        
    if !can_hold_item(item):
        return false
        
    if !_constraint_manager.has_space_for(item):
        return false

    return true


func can_hold_item(item: InventoryItem) -> bool:
    return true


func create_and_add_item(prototype_id: String) -> InventoryItem:
    var item: InventoryItem = InventoryItem.new()
    item.protoset = item_protoset
    item.prototype_id = prototype_id
    if add_item(item):
        return item
    else:
        item.free()
        return null


func remove_item(item: InventoryItem) -> bool:
    if !_can_remove_item(item):
        return false

    remove_child(item)
    return true


func _can_remove_item(item: InventoryItem) -> bool:
    return item != null && has_item(item)


func remove_all_items() -> void:
    while get_child_count() > 0:
        remove_child(get_child(0))
    _items = []


func get_item_by_id(prototype_id: String) -> InventoryItem:
    for item in get_items():
        if item.prototype_id == prototype_id:
            return item
            
    return null


func get_items_by_id(prototype_id: String) -> Array[InventoryItem]:
    var result: Array[InventoryItem] = []

    for item in get_items():
        if item.prototype_id == prototype_id:
            result.append(item)
            
    return result


func has_item_by_id(prototype_id: String) -> bool:
    return get_item_by_id(prototype_id) != null


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    if !_can_remove_item(item) || !destination.can_add_item(item):
        return false

    remove_item(item)
    destination.add_item(item)
    return true


func reset() -> void:
    clear()
    item_protoset = null
    _constraint_manager.reset()


func clear() -> void:
    for item in get_items():
        item.queue_free()
    remove_all_items()


func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_NODE_NAME] = name as String
    result[KEY_ITEM_PROTOSET] = item_protoset.resource_path
    result[KEY_CONSTRAINTS] = _constraint_manager.serialize()
    if !get_items().is_empty():
        result[KEY_ITEMS] = []
        for item in get_items():
            result[KEY_ITEMS].append(item.serialize())

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_ITEM_PROTOSET, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY) ||\
        !Verify.dict(source, false, KEY_CONSTRAINTS, TYPE_DICTIONARY):
        return false

    clear()
    item_protoset = null

    if !source[KEY_NODE_NAME].is_empty() && source[KEY_NODE_NAME] != name:
        name = source[KEY_NODE_NAME]
    item_protoset = load(source[KEY_ITEM_PROTOSET])
    # TODO: Check return value:
    if source.has(KEY_CONSTRAINTS):
        _constraint_manager.deserialize(source[KEY_CONSTRAINTS])
    if source.has(KEY_ITEMS):
        var items = source[KEY_ITEMS]
        for item_dict in items:
            var item = _get_item_script().new()
            # TODO: Check return value:
            item.deserialize(item_dict)
            assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.prototype_id)

    return true

