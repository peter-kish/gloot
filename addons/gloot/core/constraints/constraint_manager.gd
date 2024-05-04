extends RefCounted

signal constraint_enabled
signal constraint_disabled
signal pre_constraint_disabled

const KEY_WEIGHT_CONSTRAINT = "weight_constraint"
const KEY_GRID_CONSTRAINT = "grid_constraint"

const Verify = preload("res://addons/gloot/core/verify.gd")
const WeightConstraint = preload("res://addons/gloot/core/constraints/weight_constraint.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

var _weight_constraint: WeightConstraint = null
var _grid_constraint: GridConstraint = null
var _weight_constraint_enabled := false
var _stacks_constraint_enabled := false
var _grid_constraint_enabled := false
var inventory: Inventory = null :
    set(new_inventory):
        assert(new_inventory != null, "Can't set inventory to null!")
        assert(inventory == null, "Inventory already set!")
        inventory = new_inventory
        if _weight_constraint != null:
            _weight_constraint.inventory = inventory
        if _grid_constraint != null:
            _grid_constraint.inventory = inventory

enum Configuration {WG, W, G, VANILLA}


func _init(inventory_: Inventory) -> void:
    inventory = inventory_
    _weight_constraint = WeightConstraint.new(inventory)
    _grid_constraint = GridConstraint.new(inventory)


func _on_item_added(item: InventoryItem) -> void:
    assert(_enforce_constraints(item), "Failed to enforce constraints!")

    # Enforcing constraints can result in the item being removed from the inventory
    # (e.g. when it's merged with another item stack)
    if !is_instance_valid(item.get_inventory()):
        item = null
    
    if _weight_constraint_enabled:
        _weight_constraint._on_item_added(item)
    if _grid_constraint_enabled:
        _grid_constraint._on_item_added(item)


func _on_item_removed(item: InventoryItem) -> void:
    if _weight_constraint_enabled:
        _weight_constraint._on_item_removed(item)
    if _grid_constraint_enabled:
        _grid_constraint._on_item_removed(item)


func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    if _weight_constraint_enabled:
        _weight_constraint._on_item_property_changed(item, property)
    if _grid_constraint_enabled:
        _grid_constraint._on_item_property_changed(item, property)


func _on_pre_item_swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    if _weight_constraint != null && !_weight_constraint._on_pre_item_swap(item1, item2):
        return false
    if _grid_constraint != null && !_grid_constraint._on_pre_item_swap(item1, item2):
        return false
    return true


func _on_post_item_swap(item1: InventoryItem, item2: InventoryItem) -> void:
    if _weight_constraint != null:
        _weight_constraint._on_post_item_swap(item1, item2)
    if _grid_constraint != null:
        _grid_constraint._on_post_item_swap(item1, item2)


func _enforce_constraints(item: InventoryItem) -> bool:
    match get_configuration():
        Configuration.G:
            return _grid_constraint.move_item_to_free_spot(item)
        Configuration.WG:
            return _grid_constraint.move_item_to_free_spot(item)

    return true


func get_configuration() -> int:
    if _weight_constraint_enabled && _grid_constraint_enabled:
        return Configuration.WG

    if _weight_constraint_enabled:
        return Configuration.W

    if _grid_constraint_enabled:
        return Configuration.G

    return Configuration.VANILLA


func get_space_for(item: InventoryItem) -> ItemCount:
    match get_configuration():
        Configuration.W:
            return _weight_constraint.get_space_for(item)
        Configuration.G:
            return _grid_constraint.get_space_for(item)
        Configuration.WG:
            return ItemCount.min(_grid_constraint.get_space_for(item), _weight_constraint.get_space_for(item))

    return ItemCount.inf()


func has_space_for(item: InventoryItem) -> bool:
    match get_configuration():
        Configuration.W:
            return _weight_constraint.has_space_for(item)
        Configuration.G:
            return _grid_constraint.has_space_for(item)
        Configuration.WG:
            return _weight_constraint.has_space_for(item) && _grid_constraint.has_space_for(item)

    return true


func enable_weight_constraint(capacity: float = 0.0) -> void:
    assert(!_weight_constraint_enabled, "Weight constraint is already enabled")
    _weight_constraint_enabled = true
    _weight_constraint.capacity = capacity
    constraint_enabled.emit(Inventory.Constraint.WEIGHT)


func enable_grid_constraint(size: Vector2i = GridConstraint.DEFAULT_SIZE) -> void:
    assert(!_grid_constraint_enabled, "Grid constraint is already enabled")
    _grid_constraint_enabled = true
    _grid_constraint.size = size
    constraint_enabled.emit(Inventory.Constraint.GRID)


func disable_weight_constraint() -> void:
    assert(_weight_constraint_enabled, "Weight constraint is already disabled")
    pre_constraint_disabled.emit(Inventory.Constraint.WEIGHT)
    _weight_constraint_enabled = false
    constraint_disabled.emit(Inventory.Constraint.WEIGHT)


func disable_grid_constraint() -> void:
    assert(_grid_constraint_enabled, "Grid constraint is already disabled")
    pre_constraint_disabled.emit(Inventory.Constraint.GRID)
    _grid_constraint_enabled = false
    constraint_disabled.emit(Inventory.Constraint.GRID)


func get_weight_constraint() -> WeightConstraint:
    if _weight_constraint_enabled:
        return _weight_constraint
    return null


func get_grid_constraint() -> GridConstraint:
    if _grid_constraint_enabled:
        return _grid_constraint
    return null


func reset() -> void:
    if _weight_constraint_enabled:
        disable_weight_constraint()
    if _grid_constraint_enabled:
        disable_grid_constraint()


func serialize() -> Dictionary:
    var result := {}

    if get_weight_constraint():
        result[KEY_WEIGHT_CONSTRAINT] = get_weight_constraint().serialize()
    if get_grid_constraint():
        result[KEY_GRID_CONSTRAINT] = get_grid_constraint().serialize()

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_WEIGHT_CONSTRAINT, TYPE_DICTIONARY):
        return false
    if !Verify.dict(source, false, KEY_GRID_CONSTRAINT, TYPE_DICTIONARY):
        return false

    reset()

    if source.has(KEY_WEIGHT_CONSTRAINT):
        enable_weight_constraint()
        if !get_weight_constraint().deserialize(source[KEY_WEIGHT_CONSTRAINT]):
            return false
    if source.has(KEY_GRID_CONSTRAINT):
        enable_grid_constraint()
        if !get_grid_constraint().deserialize(source[KEY_GRID_CONSTRAINT]):
            return false

    return true
