@tool
@icon("res://addons/gloot/images/icon_inventory.svg")
extends Node
class_name Inventory
## Basic stack-based inventory class.
##
## Supports basic inventory operations (adding, removing, transferring items etc.). Can contain an unlimited amount of item stacks.

signal item_added(item)                         ## Emitted when an item has been added to the inventory.
signal item_removed(item)                       ## Emitted when an item has been removed from the inventory.
signal item_property_changed(item, property)    ## Emitted when a property of an item inside the inventory has been changed.
signal item_moved(item)                         ## Emitted when an item has moved to a new index.
signal prototree_json_changed                   ## Emitted when the prototree_json property has changed.
signal constraint_added(constraint)             ## Emitted when a new constraint has been added to the inventory.
signal constraint_removed(constraint)           ## Emitted when a constraint has been removed from the inventory.
signal constraint_changed(constraint)           ## Emitted when an inventory constraint has changed.

const StackManager = preload("res://addons/gloot/core/stack_manager.gd")
const ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")
const Utils = preload("res://addons/gloot/core/utils.gd")

## A JSON resource containing prototree information.
@export var prototree_json: JSON :
    set(new_prototree_json):
        if new_prototree_json == prototree_json:
            return
        clear()
        _disconnect_prototree_json_signals()
        prototree_json = new_prototree_json
        _prototree.deserialize(prototree_json)
        _connect_prototree_json_signals()
        prototree_json_changed.emit()
        update_configuration_warnings()

var _prototree := ProtoTree.new()

var _items: Array[InventoryItem] = []
var _constraint_manager: ConstraintManager = null
var _serialized_format: Dictionary:
    set(new_serialized_format):
        _serialized_format = new_serialized_format

const KEY_NODE_NAME: String = "node_name"
const KEY_PROTOTREE: String = "prototree"
const KEY_CONSTRAINTS: String = "constraints"
const KEY_ITEMS: String = "items"
const KEY_STACK_SIZE = StackManager.KEY_STACK_SIZE
const KEY_MAX_STACK_SIZE = StackManager.KEY_MAX_STACK_SIZE
const Verify = preload("res://addons/gloot/core/verify.gd")


## Returns the inventory prototree parsed from the prototree_json JSON resource.
func get_prototree() -> ProtoTree:
    # TODO: Consider returning null when prototree_json is null
    return _prototree


func _disconnect_prototree_json_signals() -> void:
    if !is_instance_valid(prototree_json):
        return
    prototree_json.changed.disconnect(_on_prototree_json_changed)


func _connect_prototree_json_signals() -> void:
    if !is_instance_valid(prototree_json):
        return
    prototree_json.changed.connect(_on_prototree_json_changed)


func _on_prototree_json_changed() -> void:
    prototree_json_changed.emit()

    
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
    if prototree_json == null:
        return PackedStringArray([
                "This inventory node has no prototree. Set the 'prototree_json' field to be able to " \
                + "populate the inventory with items."])
    return PackedStringArray()


static func _get_item_script() -> Script:
    return preload("inventory_item.gd")


func _init() -> void:
    _constraint_manager = ConstraintManager.new(self)
    _constraint_manager.constraint_changed.connect(_on_constraint_changed)


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
    _update_serialized_format()
    constraint_changed.emit(constraint)


func _ready() -> void:
    renamed.connect(_update_serialized_format)

    if !_serialized_format.is_empty():
        deserialize(_serialized_format)

    for item in get_items():
        _connect_item_signals(item)


## Moves the item at the given index in the inventory to a new index.
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

    item_moved.emit()


## Returns the index of the given item in the inventory.
func get_item_index(item: InventoryItem) -> int:
    return _items.find(item)


## Returns the number of items in the inventory.
func get_item_count() -> int:
    return _items.size()


func _connect_item_signals(item: InventoryItem) -> void:
    Utils.safe_connect(item.property_changed, _on_item_property_changed.bind(item))


func _disconnect_item_signals(item:InventoryItem) -> void:
    Utils.safe_disconnect(item.property_changed, _on_item_property_changed)


func _on_item_property_changed(property: String, item: InventoryItem) -> void:
    _update_serialized_format()
    _constraint_manager._on_item_property_changed(item, property)
    item_property_changed.emit(item, property)


## Returns an array containing all the items in the inventory.
func get_items() -> Array[InventoryItem]:
    return _items


## Checks if the inventory contains the given item.
func has_item(item: InventoryItem) -> bool:
    return item in _items


## Adds the given item to the inventory.
func add_item(item: InventoryItem) -> bool:
    if !can_add_item(item):
        return false

    if item.get_inventory() != null:
        item.get_inventory().remove_item(item)

    _items.append(item)
    _update_serialized_format()
    item._inventory = self
    _connect_item_signals(item)
    _constraint_manager._on_item_added(item)
    # Adding an item can result in the item being freed (e.g. when it's merged with another item stack)
    if !is_instance_valid(item):
        item = null
    item_added.emit(item)
    return true


## Checks if the given item can be added to the inventory.
func can_add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false
        
    if !_constraint_manager.has_space_for(item):
        return false

    return true


## Creates an `InventoryItem` based on the given prototype path adds it to the inventory. Returns `null` if the item
## cannot be added.
func create_and_add_item(prototype_path: String) -> InventoryItem:
    var item: InventoryItem = InventoryItem.new(prototree_json, prototype_path)
    if add_item(item):
        return item
    else:
        return null


## Removes the given item from the inventory. Returns `false` if the item is not inside the inventory.
func remove_item(item: InventoryItem) -> bool:
    if !_can_remove_item(item):
        return false

    _items.erase(item)
    _update_serialized_format()
    item._inventory = null
    _disconnect_item_signals(item)
    _constraint_manager._on_item_removed(item)
    item_removed.emit(item)
    return true


func _can_remove_item(item: InventoryItem) -> bool:
    return item != null && has_item(item)


## Returns the first found item with the given prototype path. 
func get_item_with_prototype_path(prototype_path: String) -> InventoryItem:
    for item in get_items():
        if _is_item_at_path(item, prototype_path):
            return item
            
    return null


## Returns an array of all the items with the given prototype path.
func get_items_with_prototype_path(prototype_path: String) -> Array[InventoryItem]:
    var result: Array[InventoryItem] = []

    for item in get_items():
        if _is_item_at_path(item, prototype_path):
            result.append(item)
            
    return result


func _is_item_at_path(item: InventoryItem, path: String) -> bool:
    var prototype := item.get_prototree().get_prototype(path)
    if !is_instance_valid(prototype):
        return false

    var prototype_path := item.get_prototree().get_prototype(path).get_path()
    var abs_item_path := item.get_prototype().get_path()
    return abs_item_path.equal(prototype_path)


## Checks if the inventory has an item with the given prototype path.
func has_item_with_prototype_path(prototype_path: String) -> bool:
    return get_item_with_prototype_path(prototype_path) != null


func _on_constraint_added(constraint: InventoryConstraint) -> void:
    _constraint_manager.register_constraint(constraint)
    constraint_added.emit(constraint)

    
func _on_constraint_removed(constraint: InventoryConstraint) -> void:
    _constraint_manager.unregister_constraint(constraint)
    constraint_removed.emit(constraint)


## Returns the inventory constraint of the given type (script). Returns `null` if the inventory has no constraints of
## that type.
func get_constraint(script: Script) -> InventoryConstraint:
    return _constraint_manager.get_constraint(script)


## Removes all items from the inventory and sets its prototree to `null`.
func reset() -> void:
    clear()
    prototree_json = null


## Removes all the items from the inventory.
func clear() -> void:
    while _items.size() > 0:
        remove_item(_items[0])
    _update_serialized_format()


## Serializes the inventory into a `Dictionary`.
func serialize() -> Dictionary:
    var result: Dictionary = {}

    if prototree_json == null || _constraint_manager == null:
        return result

    result[KEY_NODE_NAME] = name as String
    result[KEY_PROTOTREE] = _serialize_prototree_json(prototree_json)
    if !_constraint_manager.is_empty():
        result[KEY_CONSTRAINTS] = _constraint_manager.serialize()
    if !get_items().is_empty():
        result[KEY_ITEMS] = []
        for item in get_items():
            result[KEY_ITEMS].append(item.serialize())

    return result


static func _serialize_prototree_json(prototree_json: JSON) -> String:
    if !is_instance_valid(prototree_json):
        return ""
    elif prototree_json.resource_path.is_empty():
        return prototree_json.stringify(prototree_json.data)
    else:
        return prototree_json.resource_path


## Loads the inventory data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
        !Verify.dict(source, true, KEY_PROTOTREE, TYPE_STRING) ||\
        !Verify.dict(source, false, KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY) ||\
        !Verify.dict(source, false, KEY_CONSTRAINTS, TYPE_DICTIONARY):
        return false

    clear()
    prototree_json = null

    if !source[KEY_NODE_NAME].is_empty() && source[KEY_NODE_NAME] != name:
        name = source[KEY_NODE_NAME]
    prototree_json = _deserialize_prototree_json(source[KEY_PROTOTREE])
    # TODO: Check return value:
    if source.has(KEY_ITEMS):
        var items = source[KEY_ITEMS]
        for item_dict in items:
            var item = _get_item_script().new()
            # TODO: Check return value:
            item.deserialize(item_dict)
            assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.get_title())
    if source.has(KEY_CONSTRAINTS):
        if !_constraint_manager.deserialize(source[KEY_CONSTRAINTS]):
            return false

    return true


static func _deserialize_prototree_json(data: String) -> JSON:
    if data.is_empty():
        return null
    elif data.begins_with("res://"):
        return load(data)
    else:
        var prototree := JSON.new()
        prototree.parse(data)
        return prototree


## Splits the given item stack into two within the inventory. `new_stack_size` defines the size of the new stack,
# which is added to the inventory. Returns `null` if the split cannot be performed or if the new stack cannot be added
## to the inventory.
func split_stack(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return StackManager.inv_split_stack(self, item, ItemCount.new(new_stack_size))


## Merges the `item_src` item stack into the `item_dst` stack which is inside the inventory. If `item_dst` doesn't have
## enough stack space and `split_source` is set to `true`, `item_src` will be split and only partially merged. Returns
## `false` if the merge cannot be performed.
func merge_stacks(item_dst: InventoryItem, item_src: InventoryItem, split_source: bool = false) -> bool:
    return StackManager.inv_merge_stack(self, item_dst, item_src, split_source)


## Adds the given item to the inventory and merges it with all compatible items. Returns `false` if the item cannot be
## added.
func add_item_automerge(item: InventoryItem) -> bool:
    return StackManager.inv_add_automerge(self, item)


## Adds the given item to the inventory, splitting it if there is not enough space for the whole stack.
func add_item_autosplit(item: InventoryItem) -> bool:
    return StackManager.inv_add_autosplit(self, item)


## A combination of `add_item_autosplit` and `add_item_automerge`. Adds the given item stack into the inventory, splitting it up
## and joining it with available item stacks, as needed.
func add_item_autosplitmerge(item: InventoryItem) -> bool:
    return StackManager.inv_add_autosplitmerge(self, item)


## Merges the given item with all compatible items in the same inventory.
func pack_item(item: InventoryItem) -> void:
    return StackManager.inv_pack_stack(self, item)
