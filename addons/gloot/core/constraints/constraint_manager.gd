const KEY_WEIGHT_CONSTRAINT = "weight_constraint"
const KEY_STACKS_CONSTRAINT = "stacks_constraint"
const KEY_GRID_CONSTRAINT = "grid_constraint"

const Verify = preload("res://addons/gloot/core/verify.gd")
const WeightConstraint = preload("res://addons/gloot/core/constraints/weight_constraint.gd")
const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

var _weight_constraint: WeightConstraint = null
var _stacks_constraint: StacksConstraint = null
var _grid_constraint: GridConstraint = null
var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        assert(new_inventory != null, "Can't set inventory to null!")
        assert(inventory == null, "Inventory already set!")
        inventory = new_inventory
        if _weight_constraint != null:
            _weight_constraint.inventory = inventory
        if _stacks_constraint != null:
            _stacks_constraint.inventory = inventory
        if _grid_constraint != null:
            _grid_constraint.inventory = inventory


enum Configuration {WSG, WS, WG, SG, W, S, G, VANILLA}


func _init(inventory_: Inventory) -> void:
    inventory = inventory_


func _on_item_added(item: InventoryItem) -> void:
    assert(_enforce_constraints(item), "Failed to enforce constraints!")
    
    if _weight_constraint != null:
        _weight_constraint._on_item_added(item)
    if _stacks_constraint != null:
        _stacks_constraint._on_item_added(item)
    if _grid_constraint != null:
        _grid_constraint._on_item_added(item)


func _on_item_removed(item: InventoryItem) -> void:
    if _weight_constraint != null:
        _weight_constraint._on_item_removed(item)
    if _stacks_constraint != null:
        _stacks_constraint._on_item_removed(item)
    if _grid_constraint != null:
        _grid_constraint._on_item_removed(item)


func _on_item_modified(item: InventoryItem) -> void:
    if _weight_constraint != null:
        _weight_constraint._on_item_modified(item)
    if _stacks_constraint != null:
        _stacks_constraint._on_item_modified(item)
    if _grid_constraint != null:
        _grid_constraint._on_item_modified(item)


func _enforce_constraints(item: InventoryItem) -> bool:
    match get_configuration():
        Configuration.G:
            return _grid_constraint.move_item_to_free_spot(item)
        Configuration.WG:
            return _grid_constraint.move_item_to_free_spot(item)
        Configuration.SG:
            if _grid_constraint.move_item_to_free_spot(item):
                return true
            _stacks_constraint.pack_item(item)
        Configuration.WSG:
            if _grid_constraint.move_item_to_free_spot(item):
                return true
            _stacks_constraint.pack_item(item)

    return true


func get_configuration() -> int:
    if _weight_constraint && _stacks_constraint && _grid_constraint:
        return Configuration.WSG

    if _weight_constraint && _stacks_constraint:
        return Configuration.WS

    if _weight_constraint && _grid_constraint:
        return Configuration.WG

    if _stacks_constraint && _grid_constraint:
        return Configuration.SG

    if _weight_constraint:
        return Configuration.W

    if _stacks_constraint:
        return Configuration.S

    if _grid_constraint:
        return Configuration.G

    return Configuration.VANILLA


func get_space_for(item: InventoryItem) -> ItemCount:
    match get_configuration():
        Configuration.W:
            return _weight_constraint.get_space_for(item)
        Configuration.S:
            return _stacks_constraint.get_space_for(item)
        Configuration.G:
            return _grid_constraint.get_space_for(item)
        Configuration.WS:
            return _ws_get_space_for(item)
        Configuration.WG:
            return ItemCount.min(_grid_constraint.get_space_for(item), _weight_constraint.get_space_for(item))
        Configuration.SG:
            return _sg_get_space_for(item)
        Configuration.WSG:
            return ItemCount.min(_sg_get_space_for(item), _ws_get_space_for(item))

    return ItemCount.inf()


func _ws_get_space_for(item: InventoryItem) -> ItemCount:
    var stack_size := ItemCount.new(_stacks_constraint.get_item_stack_size(item))
    var result := _weight_constraint.get_space_for(item).div(stack_size)
    return result


func _sg_get_space_for(item: InventoryItem) -> ItemCount:
    var grid_space := _grid_constraint.get_space_for(item)
    var max_stack_size := ItemCount.new(_stacks_constraint.get_item_max_stack_size(item))
    var stack_size := ItemCount.new(_stacks_constraint.get_item_stack_size(item))
    var free_stacks_space := _stacks_constraint.get_free_stack_space_for(item)
    return grid_space.mul(max_stack_size).add(free_stacks_space).div(stack_size)


func has_space_for(item: InventoryItem) -> bool:
    return not get_space_for(item).less(ItemCount.new(1))


func enable_weight_constraint_(capacity: float = 0.0) -> void:
    assert(_weight_constraint == null, "Weight constraint is already enabled")
    _weight_constraint = WeightConstraint.new(inventory)
    _weight_constraint.capacity = capacity


func enable_stacks_constraint_() -> void:
    assert(_stacks_constraint == null, "Stacks constraint is already enabled")
    _stacks_constraint = StacksConstraint.new(inventory)


func enable_grid_constraint(size: Vector2i = GridConstraint.DEFAULT_SIZE) -> void:
    assert(_grid_constraint == null, "Grid constraint is already enabled")
    _grid_constraint = GridConstraint.new(inventory)
    _grid_constraint.size = size


func get_weight_constraint() -> WeightConstraint:
    return _weight_constraint


func get_stacks_constraint() -> StacksConstraint:
    return _stacks_constraint


func get_grid_constraint() -> GridConstraint:
    return _grid_constraint


func reset() -> void:
    if get_weight_constraint():
        get_weight_constraint().reset()
    if get_stacks_constraint():
        get_stacks_constraint().reset()
    if get_grid_constraint():
        get_grid_constraint().reset()


func serialize() -> Dictionary:
    var result := {}

    if get_weight_constraint():
        result[KEY_WEIGHT_CONSTRAINT] = get_weight_constraint().serialize()
    if get_stacks_constraint():
        result[KEY_STACKS_CONSTRAINT] = get_stacks_constraint().serialize()
    if get_grid_constraint():
        result[KEY_GRID_CONSTRAINT] = get_grid_constraint().serialize()

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_WEIGHT_CONSTRAINT, TYPE_DICTIONARY):
        return false
    if !Verify.dict(source, false, KEY_STACKS_CONSTRAINT, TYPE_DICTIONARY):
        return false
    if !Verify.dict(source, false, KEY_GRID_CONSTRAINT, TYPE_DICTIONARY):
        return false

    reset()

    if source.has(KEY_WEIGHT_CONSTRAINT):
        if !get_weight_constraint().deserialize(source[KEY_WEIGHT_CONSTRAINT]):
            return false
    if source.has(KEY_STACKS_CONSTRAINT):
        if !get_stacks_constraint().deserialize(source[KEY_STACKS_CONSTRAINT]):
            return false
    if source.has(KEY_GRID_CONSTRAINT):
        if !get_grid_constraint().deserialize(source[KEY_GRID_CONSTRAINT]):
            return false

    return true
