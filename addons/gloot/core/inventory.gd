@tool
@icon("res://addons/gloot/images/icon_inventory.svg")
extends Node
class_name Inventory

## Basic inventory class.
##
## Supports basic inventory operations (adding, removing, transferring items
## etc.).
## Can contain an unlimited amount of items.

## Emitted when an item has been added to the inventory.
signal item_added(item)
## Emitted when an item has been removed from the inventory.
signal item_removed(item)
## Emitted when an item from the inventory has been modified.
signal item_modified(item)
## Emitted when a property of an item from the inventory has been changed.
signal item_property_changed(item, property_name)
## Emitted when the contents of the inventory have changed.
signal contents_changed
## Emitted when the [member item_protoset] property has been changed.
signal protoset_changed

const ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")

## An [ItemProtoset] resource containing item prototypes.
@export var item_protoset: ItemProtoset:
    set(new_item_protoset):
        if new_item_protoset == item_protoset:
            return
        clear()
        _disconnect_protoset_signals()
        item_protoset = new_item_protoset
        _connect_protoset_signals()
        protoset_changed.emit()
        update_configuration_warnings()
var _items: Array[InventoryItem] = []
var _constraint_manager: ConstraintManager = null

const KEY_NODE_NAME: String = "node_name"
const KEY_ITEM_PROTOSET: String = "item_protoset"
const KEY_CONSTRAINTS: String = "constraints"
const KEY_ITEMS: String = "items"
const Verify = preload("res://addons/gloot/core/verify.gd")


func _disconnect_protoset_signals() -> void:
    if !is_instance_valid(item_protoset):
        return
    item_protoset.changed.disconnect(_on_protoset_changed)


func _connect_protoset_signals() -> void:
    if !is_instance_valid(item_protoset):
        return
    item_protoset.changed.connect(_on_protoset_changed)


func _on_protoset_changed() -> void:
    protoset_changed.emit()


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


func _init() -> void:
    _constraint_manager = ConstraintManager.new(self)


func _ready() -> void:
    for item in get_items():
        _connect_item_signals(item)


func _on_item_added(item: InventoryItem) -> void:
    _items.append(item)
    contents_changed.emit()
    _connect_item_signals(item)
    if _constraint_manager:
        _constraint_manager._on_item_added(item)
    item_added.emit(item)


func _on_item_removed(item: InventoryItem) -> void:
    _items.erase(item)
    contents_changed.emit()
    _disconnect_item_signals(item)
    if _constraint_manager:
        _constraint_manager._on_item_removed(item)
    item_removed.emit(item)

## Moves the item at index [param from] to the index [param to].
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

## Returns the internal item index of the given item. Returns [code]-1[/code]
## if the item is not inside the inventory.
func get_item_index(item: InventoryItem) -> int:
    return _items.find(item)

## Returns the number of items in the inventory.
func get_item_count() -> int:
    return _items.size()


func _connect_item_signals(item: InventoryItem) -> void:
    if !item.protoset_changed.is_connected(_emit_item_modified):
        item.protoset_changed.connect(_emit_item_modified.bind(item))
    if !item.prototype_id_changed.is_connected(_emit_item_modified):
        item.prototype_id_changed.connect(_emit_item_modified.bind(item))
    if !item.properties_changed.is_connected(_emit_item_modified):
        item.properties_changed.connect(_emit_item_modified.bind(item))
    if !item.property_changed.is_connected(_on_item_property_changed):
        item.property_changed.connect(_on_item_property_changed.bind(item))


func _disconnect_item_signals(item:InventoryItem) -> void:
    if item.protoset_changed.is_connected(_emit_item_modified):
        item.protoset_changed.disconnect(_emit_item_modified)
    if item.prototype_id_changed.is_connected(_emit_item_modified):
        item.prototype_id_changed.disconnect(_emit_item_modified)
    if item.properties_changed.is_connected(_emit_item_modified):
        item.properties_changed.disconnect(_emit_item_modified)
    if item.property_changed.is_connected(_on_item_property_changed):
        item.property_changed.disconnect(_on_item_property_changed.bind(item))


func _emit_item_modified(item: InventoryItem) -> void:
    item_modified.emit(item)


func _on_item_property_changed(property_name: String, item: InventoryItem) -> void:
    _constraint_manager._on_item_property_changed(item, property_name)
    item_property_changed.emit(item, property_name)

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

    if item.get_parent():
        item.get_parent().remove_child(item)

    # HACK: In case of InventoryGridStacked we can end up adding the item and
    # removing it immediately, after a successful pack() call (in case the grid
    # constraint has no space for the item). This causes some errors because
    # Godot still tries to call the ENTER_TREE notification. To avoid that, we
    # call transfer_automerge(), which should be able to pack the item without 
    # adding it first.
    var gc := _constraint_manager.get_grid_constraint()
    var sc := _constraint_manager.get_stacks_constraint()
    if gc != null && sc != null && !gc.has_space_for(item):
        var transfer_success = sc.transfer_automerge(item, self)
        assert(transfer_success)
    else:
        add_child(item)

    if Engine.is_editor_hint() && !item.is_queued_for_deletion():
        item.owner = get_tree().edited_scene_root
    return true

## Checks if the given item can be added to the inventory taking inventory
## constraints (capacity, grid space etc.) and the result of [method can_hold_item]
## into account.
func can_add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false
        
    if !can_hold_item(item):
        return false
        
    if !_constraint_manager.has_space_for(item):
        return false

    return true

## Checks if the inventory can hold the given item.
## Always returns [code]true[/code] and can be overriden to make the inventory
## only accept items with specific properties. Does not check inventory
## constraints such as capacity or grid space. Those checks are done by
## [method can_add_item].
func can_hold_item(item: InventoryItem) -> bool:
    return true

## Creates an [InventoryItem] based on the given prototype ID and adds it to
## the inventory. Returns [code]null[/code] if the item cannot be added.
func create_and_add_item(prototype_id: String) -> InventoryItem:
    var item: InventoryItem = InventoryItem.new()
    item.protoset = item_protoset
    item.prototype_id = prototype_id
    if add_item(item):
        return item
    else:
        item.free()
        return null

## Removes the given item from the inventory.
func remove_item(item: InventoryItem) -> bool:
    if !_can_remove_item(item):
        return false

    remove_child(item)
    return true


func _can_remove_item(item: InventoryItem) -> bool:
    return item != null && has_item(item)

## Removes all the items from the inventory.
func remove_all_items() -> void:
    while get_child_count() > 0:
        remove_child(get_child(0))
    _items = []

## Returns the first found item with the given prototype ID.
func get_item_by_id(prototype_id: String) -> InventoryItem:
    for item in get_items():
        if item.prototype_id == prototype_id:
            return item
            
    return null

## Returns an array of items with the given prototype ID.
func get_items_by_id(prototype_id: String) -> Array[InventoryItem]:
    var result: Array[InventoryItem] = []

    for item in get_items():
        if item.prototype_id == prototype_id:
            result.append(item)
            
    return result

## Checks if the inventory contains an item with the given prototype ID.
func has_item_by_id(prototype_id: String) -> bool:
    return get_item_by_id(prototype_id) != null

## Transfers the given item into the given inventory.
func transfer(item: InventoryItem, destination: Inventory) -> bool:
    return destination.add_item(item)

## Resets the inventory to its default state.
## This includes clearing its contents and resetting all properties.
func reset() -> void:
    clear()
    item_protoset = null
    _constraint_manager.reset()

## Clears all items from the inventory.
func clear() -> void:
    for item in get_items():
        item.queue_free()
    remove_all_items()

## Serializes the inventory into a dictionary.
func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_NODE_NAME] = name as String
    result[KEY_ITEM_PROTOSET] = _serialize_item_protoset(item_protoset)
    result[KEY_CONSTRAINTS] = _constraint_manager.serialize()
    if !get_items().is_empty():
        result[KEY_ITEMS] = []
        for item in get_items():
            result[KEY_ITEMS].append(item.serialize())

    return result


static func _serialize_item_protoset(item_protoset: ItemProtoset) -> String:
    if !is_instance_valid(item_protoset):
        return ""
    elif item_protoset.resource_path.is_empty():
        return item_protoset.json_data
    else:
        return item_protoset.resource_path

## Loads the inventory data from the given dictionary.
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
    item_protoset = _deserialize_item_protoset(source[KEY_ITEM_PROTOSET])
    # TODO: Check return value:
    if source.has(KEY_CONSTRAINTS):
        _constraint_manager.deserialize(source[KEY_CONSTRAINTS])
    if source.has(KEY_ITEMS):
        var items = source[KEY_ITEMS]
        for item_dict in items:
            var item = _get_item_script().new()
            # TODO: Check return value:
            item.deserialize(item_dict)
            var add_item_success = add_item(item)
            assert(add_item_success, "Failed to add item '%s'. Inventory full?" % item.prototype_id)

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

