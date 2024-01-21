@tool
@icon("res://addons/gloot/images/icon_inventory.svg")
extends Node
class_name Inventory

signal item_added(item)
signal item_removed(item)
signal item_property_changed(item, property)
signal item_protoset_changed(item)
signal item_prototype_id_changed(item)
signal contents_changed
signal protoset_changed
signal constraint_enabled(constraint)
signal constraint_disabled(constraint)

const ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")
const WeightConstraint = preload("res://addons/gloot/core/constraints/weight_constraint.gd")
const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

enum Constraint {WEIGHT, STACKS, GRID}

@export var protoset: ItemProtoset:
    get:
        return protoset
    set(new_protoset):
        if new_protoset == protoset:
            return
        clear()
        _disconnect_protoset_signals()
        protoset = new_protoset
        _connect_protoset_signals()
        protoset_changed.emit()
        update_configuration_warnings()
var _items: Array[InventoryItem] = []
var _constraint_manager: ConstraintManager = null
var _serialized_format: Dictionary:
    get:
        return _serialized_format
    set(new_serialized_format):
        _serialized_format = new_serialized_format

const KEY_NODE_NAME: String = "node_name"
const KEY_PROTOSET: String = "protoset"
const KEY_CONSTRAINTS: String = "constraints"
const KEY_ITEMS: String = "items"
const Verify = preload("res://addons/gloot/core/verify.gd")


func _disconnect_protoset_signals() -> void:
    if !is_instance_valid(protoset):
        return
    protoset.changed.disconnect(_on_protoset_changed)


func _connect_protoset_signals() -> void:
    if !is_instance_valid(protoset):
        return
    protoset.changed.connect(_on_protoset_changed)


func _on_protoset_changed() -> void:
    protoset_changed.emit()

    
func _get_property_list():
    return [
        {
            "name": "_serialized_format",
            "type": TYPE_DICTIONARY,
            "usage": PROPERTY_USAGE_STORAGE
        },
    ]


func _update_serialized_format() -> void:
    if Engine.is_editor_hint():
        _serialized_format = serialize()


func _get_configuration_warnings() -> PackedStringArray:
    if protoset == null:
        return PackedStringArray([
                "This inventory node has no protoset. Set the 'protoset' field to be able to " \
                + "populate the inventory with items."])
    return PackedStringArray()


static func _get_item_script() -> Script:
    return preload("inventory_item.gd")


func _init() -> void:
    _constraint_manager = ConstraintManager.new(self)
    _constraint_manager.constraint_enabled.connect(_on_constraint_enabled)
    _constraint_manager.constraint_disabled.connect(func(constraint: int): constraint_disabled.emit(constraint))


func _on_constraint_enabled(constraint: int) -> void:
    if constraint != ConstraintManager.Constraint.GRID:
        return
    var grid_constraint := _constraint_manager.get_grid_constraint()
    if !grid_constraint.size_changed.is_connected(_update_serialized_format):
        grid_constraint.size_changed.connect(_update_serialized_format)
    if !grid_constraint.item_moved.is_connected(_on_item_moved):
        grid_constraint.item_moved.connect(_on_item_moved)
    constraint_enabled.emit(constraint)


func _ready() -> void:
    if !_serialized_format.is_empty():
        deserialize(_serialized_format)
    for item in get_items():
        _connect_item_signals(item)


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
    _update_serialized_format()

    contents_changed.emit()


func get_item_index(item: InventoryItem) -> int:
    return _items.find(item)


func get_item_count() -> int:
    return _items.size()


func _connect_item_signals(item: InventoryItem) -> void:
    if !item.protoset_changed.is_connected(_on_item_protoset_changed):
        item.protoset_changed.connect(_on_item_protoset_changed.bind(item))
    if !item.prototype_id_changed.is_connected(_on_item_prototype_id_changed):
        item.prototype_id_changed.connect(_on_item_prototype_id_changed.bind(item))
    if !item.property_changed.is_connected(_on_item_property_changed):
        item.property_changed.connect(_on_item_property_changed.bind(item))


func _disconnect_item_signals(item:InventoryItem) -> void:
    if item.protoset_changed.is_connected(_on_item_protoset_changed):
        item.protoset_changed.disconnect(_on_item_protoset_changed)
    if item.prototype_id_changed.is_connected(_on_item_prototype_id_changed):
        item.prototype_id_changed.disconnect(_on_item_prototype_id_changed)
    if item.property_changed.is_connected(_on_item_property_changed):
        item.property_changed.disconnect(_on_item_property_changed)


func _on_item_property_changed(property: String, item: InventoryItem) -> void:
    _update_serialized_format()
    _constraint_manager._on_item_property_changed(item, property)
    item_property_changed.emit(item, property)


func _on_item_protoset_changed(item: InventoryItem) -> void:
    _update_serialized_format()
    _constraint_manager._on_item_protoset_changed(item)
    item_protoset_changed.emit(item)


func _on_item_prototype_id_changed(item: InventoryItem) -> void:
    _update_serialized_format()
    _constraint_manager._on_item_prototype_id_changed(item)
    item_prototype_id_changed.emit(item)


func get_items() -> Array[InventoryItem]:
    return _items


func has_item(item: InventoryItem) -> bool:
    return item in _items


func add_item(item: InventoryItem) -> bool:
    if !can_add_item(item):
        return false

    if item.get_item_slot() != null:
        item.get_item_slot().clear()
    if item.get_inventory() != null:
        item.get_inventory().remove_item(item)

    _items.append(item)
    _update_serialized_format()
    item._inventory = self
    contents_changed.emit()
    _connect_item_signals(item)
    _constraint_manager._on_item_added(item)
    # Adding an item can result in the item being freed (e.g. when it's merged with another item stack)
    if !is_instance_valid(item):
        item = null
    item_added.emit(item)
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
    item.protoset = protoset
    item.prototype_id = prototype_id
    if add_item(item):
        return item
    else:
        return null


func remove_item(item: InventoryItem) -> bool:
    if !_can_remove_item(item):
        return false

    _items.erase(item)
    _update_serialized_format()
    item._inventory = null
    contents_changed.emit()
    _disconnect_item_signals(item)
    _constraint_manager._on_item_removed(item)
    item_removed.emit(item)
    return true


func _can_remove_item(item: InventoryItem) -> bool:
    return item != null && has_item(item)


func remove_all_items() -> void:
    while _items.size() > 0:
        remove_item(_items[0])
    # TODO: Check if this is neccessary:
    _update_serialized_format()


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
    return destination.add_item(item)


func enable_weight_constraint(capacity: float = 0) -> void:
    assert(_constraint_manager != null, "Missing constraint manager!")
    _constraint_manager.enable_weight_constraint(capacity)


func enable_stacks_constraint() -> void:
    assert(_constraint_manager != null, "Missing constraint manager!")
    _constraint_manager.enable_stacks_constraint()


func enable_grid_constraint(size: Vector2i = GridConstraint.DEFAULT_SIZE) -> void:
    assert(_constraint_manager != null, "Missing constraint manager!")
    _constraint_manager.enable_grid_constraint(size)


func disable_weight_constraint(capacity: float = 0) -> void:
    assert(_constraint_manager != null, "Missing constraint manager!")
    _constraint_manager.disable_weight_constraint()


func disable_stacks_constraint() -> void:
    assert(_constraint_manager != null, "Missing constraint manager!")
    _constraint_manager.disable_stacks_constraint()


func disable_grid_constraint(size: Vector2i = GridConstraint.DEFAULT_SIZE) -> void:
    assert(_constraint_manager != null, "Missing constraint manager!")
    _constraint_manager.disable_grid_constraint()


func get_weight_constraint() -> WeightConstraint:
    assert(_constraint_manager != null, "Missing constraint manager!")
    return _constraint_manager.get_weight_constraint()


func get_stacks_constraint() -> StacksConstraint:
    assert(_constraint_manager != null, "Missing constraint manager!")
    return _constraint_manager.get_stacks_constraint()


func get_grid_constraint() -> GridConstraint:
    assert(_constraint_manager != null, "Missing constraint manager!")
    return _constraint_manager.get_grid_constraint()


func _on_item_moved(item: InventoryItem) -> void:
    _update_serialized_format()


func reset() -> void:
    clear()
    protoset = null
    _constraint_manager.reset()


func clear() -> void:
    while _items.size() > 0:
        var item = _items[0]
        remove_item(item)
    _update_serialized_format()


func serialize() -> Dictionary:
    var result: Dictionary = {}

    if protoset == null || _constraint_manager == null:
        return result

    result[KEY_NODE_NAME] = name as String
    result[KEY_ITEM_PROTOSET] = _serialize_item_protoset(protoset)
    result[KEY_CONSTRAINTS] = _constraint_manager.serialize()
    if !get_items().is_empty():
        result[KEY_ITEMS] = []
        for item in get_items():
            result[KEY_ITEMS].append(item.serialize())

    return result


static func _serialize_item_protoset(protoset: ItemProtoset) -> String:
    if !is_instance_valid(protoset):
        return ""
    elif protoset.resource_path.is_empty():
        return protoset.json_data
    else:
        return protoset.resource_path


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOSET, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY) ||\
        !Verify.dict(source, false, KEY_CONSTRAINTS, TYPE_DICTIONARY):
        return false

    clear()
    protoset = null

    if !source[KEY_NODE_NAME].is_empty() && source[KEY_NODE_NAME] != name:
        name = source[KEY_NODE_NAME]
    protoset = _deserialize_item_protoset(source[KEY_ITEM_PROTOSET])
    # TODO: Check return value:
    if source.has(KEY_ITEMS):
        var items = source[KEY_ITEMS]
        for item_dict in items:
            var item = _get_item_script().new()
            # TODO: Check return value:
            item.deserialize(item_dict)
            assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.prototype_id)
    if source.has(KEY_CONSTRAINTS):
        _constraint_manager.deserialize(source[KEY_CONSTRAINTS])

    return true


static func _deserialize_item_protoset(data: String) -> ItemProtoset:
    if data.is_empty():
        return null
    elif data.begins_with("res://"):
        return load(data)
    else:
        var protoset := ItemProtoset.new()
        protoset.json_data = data
        return protoset

