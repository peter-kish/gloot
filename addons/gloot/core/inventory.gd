@tool
@icon("res://addons/gloot/images/icon_inventory.svg")
extends Node
class_name Inventory
## Basic stack-based inventory class.
##
## Supports basic inventory operations (adding, removing, transferring items etc.). Can contain an unlimited amount of item stacks.

signal item_added(item: InventoryItem) ## Emitted when an item has been added to the inventory.
signal item_removed(item: InventoryItem) ## Emitted when an item has been removed from the inventory.
signal item_property_changed(item: InventoryItem, property: String) ## Emitted when a property of an item inside the inventory has been changed.
signal item_moved(item: InventoryItem) ## Emitted when an item has moved to a new index.
signal protoset_changed ## Emitted when the protoset property has changed.
signal constraint_added(constraint: InventoryConstraint) ## Emitted when a new constraint has been added to the inventory.
signal constraint_removed(constraint: InventoryConstraint) ## Emitted when a constraint has been removed from the inventory.
signal constraint_changed(constraint: InventoryConstraint) ## Emitted when an inventory constraint has changed.

const _StackManager = preload("res://addons/gloot/core/stack_manager.gd")
const _ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")
const _Utils = preload("res://addons/gloot/core/utils.gd")
const _ItemCount = preload("res://addons/gloot/core/item_count.gd")
const _Verify = preload("res://addons/gloot/core/verify.gd")
const _ProtoTreeCache = preload("res://addons/gloot/core/prototree/proto_tree_cache.gd")

const _KEY_NODE_NAME: String = "node_name"
const _KEY_PROTOSET: String = "protoset"
const _KEY_CONSTRAINTS: String = "constraints"
const _KEY_ITEMS: String = "items"
const _KEY_STACK_SIZE = _StackManager._KEY_STACK_SIZE
const _KEY_MAX_STACK_SIZE = _StackManager._KEY_MAX_STACK_SIZE

## A JSON resource containing prototype information.
@export var protoset: JSON:
    set(new_protoset):
        if new_protoset == protoset:
            return
        clear()
        _disconnect_protoset_signals()
        protoset = new_protoset
        _prototree = _ProtoTreeCache.get_cached(protoset)
        _connect_protoset_signals()
        protoset_changed.emit()
        update_configuration_warnings()

var _prototree := _ProtoTreeCache.get_empty()

var _items: Array[InventoryItem] = []
var _constraint_manager: _ConstraintManager = null
var _serialized_format: Dictionary:
    set(new_serialized_format):
        _serialized_format = new_serialized_format


## Returns the inventory prototree parsed from the protoset JSON resource.
func get_prototree() -> ProtoTree:
    # TODO: Consider returning null when protoset is null
    return _prototree


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
                "This inventory node has no prototree. Set the 'protoset' field to be able to " \
                + "populate the inventory with items."])
    return PackedStringArray()


func _init() -> void:
    _constraint_manager = _ConstraintManager.new(self)
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
    _Utils.safe_connect(item.property_changed, _on_item_property_changed.bind(item))


func _disconnect_item_signals(item: InventoryItem) -> void:
    _Utils.safe_disconnect(item.property_changed, _on_item_property_changed)


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

    _add_item_unsafe(item)
    return true


func _add_item_unsafe(item: InventoryItem):
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


## Checks if the given item can be added to the inventory.
func can_add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false
        
    if !_constraint_manager.has_space_for(item):
        return false

    return true


## Creates an `InventoryItem` based on the prototype ID.
func create_item(prototype_id: String) ->InventoryItem:
    var item: InventoryItem = InventoryItem.new(protoset, prototype_id)
    return item


## Creates an `InventoryItem` based on the given prototype ID and adds it to the inventory. Returns `null` if the item
## cannot be added.
func create_and_add_item(prototype_id: String) -> InventoryItem:
    var item: InventoryItem = InventoryItem.new(protoset, prototype_id)
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


## Returns the first found item with the given prototype ID. 
func get_item_with_prototype_id(prototype_id: String) -> InventoryItem:
    for item in get_items():
        if !is_instance_valid(item.get_prototype()):
            continue
        if item.get_prototype().get_prototype_id() == prototype_id:
            return item
            
    return null


## Returns an array of all the items with the given prototype ID.
func get_items_with_prototype_id(prototype_id: String) -> Array[InventoryItem]:
    var result: Array[InventoryItem] = []

    for item in get_items():
        if !is_instance_valid(item.get_prototype()):
            continue
        if item.get_prototype().get_prototype_id() == prototype_id:
            result.append(item)
            
    return result


## Checks if the inventory has an item with the given prototype ID.
func has_item_with_prototype_id(prototype_id: String) -> bool:
    return get_item_with_prototype_id(prototype_id) != null


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


## Removes all items from the inventory and sets its protoset to `null`.
func reset() -> void:
    clear()
    protoset = null


## Removes all the items from the inventory.
func clear() -> void:
    while _items.size() > 0:
        remove_item(_items[0])
    _update_serialized_format()


## Serializes the inventory into a `Dictionary`.
func serialize() -> Dictionary:
    var result: Dictionary = {}

    if protoset == null || _constraint_manager == null:
        return result

    result[_KEY_NODE_NAME] = name as String
    result[_KEY_PROTOSET] = _serialize_protoset(protoset)
    if !_constraint_manager.is_empty():
        result[_KEY_CONSTRAINTS] = _constraint_manager.serialize()
    if !get_items().is_empty():
        result[_KEY_ITEMS] = []
        for item in get_items():
            result[_KEY_ITEMS].append(item.serialize())

    return result


static func _serialize_protoset(protoset: JSON) -> String:
    if !is_instance_valid(protoset):
        return ""
    elif protoset.resource_path.is_empty():
        return protoset.stringify(protoset.data)
    else:
        return protoset.resource_path


## Loads the inventory data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    if !_Verify.dict(source, true, _KEY_NODE_NAME, TYPE_STRING) || \
        !_Verify.dict(source, true, _KEY_PROTOSET, TYPE_STRING) || \
        !_Verify.dict(source, false, _KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY) || \
        !_Verify.dict(source, false, _KEY_CONSTRAINTS, TYPE_DICTIONARY):
        return false

    clear()
    protoset = null

    if !source[_KEY_NODE_NAME].is_empty() && source[_KEY_NODE_NAME] != name:
        name = source[_KEY_NODE_NAME]
    protoset = _Utils._deserialize_protoset(source[_KEY_PROTOSET])
    # TODO: Check return value:
    if source.has(_KEY_ITEMS):
        var items = source[_KEY_ITEMS]
        for item_dict in items:
            var item = InventoryItem.new()
            # TODO: Check return value:
            item.deserialize(item_dict)
            _add_item_unsafe(item)
    if source.has(_KEY_CONSTRAINTS):
        if !_constraint_manager.deserialize(source[_KEY_CONSTRAINTS]):
            return false

    return true


func _deserialize_undoable(source: Dictionary) -> bool:
    # ConstraintManager.deserialize() results in weird behavior when used for undo/redo
    # operations due to the creation of new nodes. ConstraintManager._deserialize_undoable()
    # should reuse existing nodes instead, but has some other limitations.

    if !_Verify.dict(source, true, _KEY_NODE_NAME, TYPE_STRING) || \
        !_Verify.dict(source, false, _KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY) || \
        !_Verify.dict(source, false, _KEY_CONSTRAINTS, TYPE_DICTIONARY):
        return false

    clear()

    if !source[_KEY_NODE_NAME].is_empty() && source[_KEY_NODE_NAME] != name:
        name = source[_KEY_NODE_NAME]
    # TODO: Check return value:
    if source.has(_KEY_ITEMS):
        var items = source[_KEY_ITEMS]
        for item_dict in items:
            var item = InventoryItem.new()
            # TODO: Check return value:
            item.deserialize(item_dict)
            _add_item_unsafe(item)
    if source.has(_KEY_CONSTRAINTS):
        if !_constraint_manager._deserialize_undoable(source[_KEY_CONSTRAINTS]):
            return false
    return true


## Splits the given item stack into two within the inventory. `new_stack_size` defines the size of the new stack,
## which is added to the inventory. Returns `null` if the split cannot be performed or if the new stack cannot be added
## to the inventory.
func split_stack(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return _StackManager.inv_split_stack(self, item, _ItemCount.new(new_stack_size))


## Merges the `item_src` item stack into the `item_dst` stack which is inside the inventory. If `item_dst` doesn't have
## enough stack space and `split_source` is set to `true`, `item_src` will be split and only partially merged. Returns
## `false` if the merge cannot be performed.
func merge_stacks(item_dst: InventoryItem, item_src: InventoryItem, split_source: bool = false) -> bool:
    return _StackManager.inv_merge_stack(self, item_dst, item_src, split_source)


## Adds the given item to the inventory and merges it with all compatible items. Returns `false` if the item cannot be
## added.
func add_item_automerge(item: InventoryItem) -> bool:
    return _StackManager.inv_add_automerge(self, item)


## Adds the given item to the inventory, splitting it if there is not enough space for the whole stack.
func add_item_autosplit(item: InventoryItem) -> bool:
    return _StackManager.inv_add_autosplit(self, item)


## A combination of `add_item_autosplit` and `add_item_automerge`. Adds the given item stack into the inventory, splitting it up
## and joining it with available item stacks, as needed.
func add_item_autosplitmerge(item: InventoryItem) -> bool:
    return _StackManager.inv_add_autosplitmerge(self, item)


## Merges the given item with all compatible items in the same inventory.
func pack_item(item: InventoryItem) -> void:
    return _StackManager.inv_pack_stack(self, item)
