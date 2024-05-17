extends RefCounted

signal constraint_changed(constraint)

var inventory: Inventory = null
var _constraints: Array[InventoryConstraint] = []


func _init(inventory_: Inventory) -> void:
    inventory = inventory_
    if !is_instance_valid(inventory):
        return
    for node in inventory.get_children():
        if !(node is InventoryConstraint):
            continue
        register_constraint(node)


func register_constraint(constraint: InventoryConstraint) -> void:
    _constraints.append(constraint)
    constraint.changed.connect(_on_constraint_changed.bind(constraint))


func unregister_constraint(constraint: InventoryConstraint) -> void:
    _constraints.erase(constraint)
    constraint.changed.disconnect(_on_constraint_changed.bind(constraint))


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
    constraint_changed.emit(constraint)


func _on_item_added(item: InventoryItem) -> void:
    assert(_enforce_constraints(item), "Failed to enforce constraints!")

    # Enforcing constraints can result in the item being removed from the inventory
    # (e.g. when it's merged with another item stack)
    if !is_instance_valid(item.get_inventory()):
        item = null
    
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


func _enforce_constraints(item: InventoryItem) -> bool:
    for constraint in _constraints:
        constraint.enforce(item)
    # TODO: Do we need a return value?
    return true


func get_space_for(item: InventoryItem) -> ItemCount:
    var min := ItemCount.inf()
    for constraint in _constraints:
        var space_for_item: ItemCount = constraint.get_space_for(item)
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

