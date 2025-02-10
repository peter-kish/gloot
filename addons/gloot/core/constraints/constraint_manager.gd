extends RefCounted

signal constraint_changed(constraint: InventoryConstraint)

const _Verify = preload("res://addons/gloot/core/verify.gd")
const _Utils = preload("res://addons/gloot/core/utils.gd")
const _ItemCount = preload("res://addons/gloot/core/item_count.gd")

const _KEY_CONSTRAINT_NAME: String = "name"
const _KEY_CONSTRAINT_DATA: String = "data"

var inventory: Inventory = null
var _constraints: Array[InventoryConstraint] = []


func _init(inventory_: Inventory) -> void:
    inventory = inventory_
    if !is_instance_valid(inventory):
        return


func is_empty() -> bool:
    return _constraints.is_empty()


func register_constraint(constraint: InventoryConstraint) -> void:
    _constraints.append(constraint)
    _Utils.safe_connect(constraint.changed, _on_constraint_changed.bind(constraint))


func unregister_constraint(constraint: InventoryConstraint) -> void:
    _constraints.erase(constraint)
    _Utils.safe_disconnect(constraint.changed, _on_constraint_changed.bind(constraint))


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
    constraint_changed.emit(constraint)


func _on_item_added(item: InventoryItem) -> void:
    for constraint in _constraints:
        constraint._on_item_added(item)


func _on_item_removed(item: InventoryItem) -> void:
    for constraint in _constraints:
        constraint._on_item_removed(item)


func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    for constraint in _constraints:
        constraint._on_item_property_changed(item, property)


func _on_pre_item_swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    for constraint in _constraints:
        if !constraint._on_pre_item_swap(item1, item2):
            return false
    return true


func _on_post_item_swap(item1: InventoryItem, item2: InventoryItem) -> void:
    for constraint in _constraints:
        constraint._on_post_item_swap(item1, item2)


func _get_constraints() -> Array[InventoryConstraint]:
    return _constraints


func get_space_for(item: InventoryItem) -> _ItemCount:
    var min := _ItemCount.inf()
    for constraint in _constraints:
        var space_for_item: _ItemCount = _ItemCount.new(constraint.get_space_for(item))
        if space_for_item.lt(min):
            min = space_for_item
    return min


func has_space_for(item: InventoryItem) -> bool:
    for constraint in _constraints:
        if !constraint.has_space_for(item):
            return false
    return true


func get_constraint(script: Script) -> InventoryConstraint:
    for constraint in _constraints:
        if constraint.get_script() == script:
            return constraint
    return null


func reset() -> void:
    while !_constraints.is_empty():
        var constraint := _constraints.pop_back()
        inventory.remove_child(constraint)
        constraint.free()


func serialize() -> Dictionary:
    var result := {}

    for constraint in _constraints:
        result[constraint.get_script().resource_path] = {
            _KEY_CONSTRAINT_NAME: constraint.name,
            _KEY_CONSTRAINT_DATA: constraint.serialize()
        }

    return result


func deserialize(source: Dictionary) -> bool:
    for constraint_script_path in source:
        if !_Verify.dict(source[constraint_script_path], true, _KEY_CONSTRAINT_NAME, [TYPE_STRING, TYPE_STRING_NAME]):
            return false
        if !_Verify.dict(source[constraint_script_path], true, _KEY_CONSTRAINT_DATA, TYPE_DICTIONARY):
            return false

    reset()

    for constraint_script_path in source:
        var constraint_script = load(constraint_script_path)
        var new_constraint: InventoryConstraint = constraint_script.new()
        new_constraint.name = source[constraint_script_path].name
        new_constraint.deserialize(source[constraint_script_path].data)
        inventory.add_child(new_constraint)
        if Engine.is_editor_hint():
            new_constraint.owner = inventory.get_tree().edited_scene_root

    return true


func _deserialize_undoable(source: Dictionary) -> bool:
    # deserialize() results in weird behavior when used for undo/redo operations
    # due to the creation of new nodes. This implementation should reuse existing
    # nodes instead, but has some other limitations.

    for constraint_script_path in source:
        if !_Verify.dict(source[constraint_script_path], true, _KEY_CONSTRAINT_NAME, [TYPE_STRING, TYPE_STRING_NAME]):
            return false
        if !_Verify.dict(source[constraint_script_path], true, _KEY_CONSTRAINT_DATA, TYPE_DICTIONARY):
            return false

    for constraint_script_path in source:
        for child in inventory.get_children():
            if child.name == source[constraint_script_path].name:
                child.deserialize(source[constraint_script_path].data)

    return true
