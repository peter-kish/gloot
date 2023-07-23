class_name ComponentManager

signal inventory_set

const KEY_WEIGHT_COMPONENT = "weight_component"
const KEY_STACKS_COMPONENT = "stacks_component"
const KEY_GRID_COMPONENT = "grid_component"

const Verify = preload("res://addons/gloot/verify.gd")

var _weight_component: WeightComponent = null
var _stacks_component: StacksComponent = null
var _grid_component: GridComponent = null
var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        assert(new_inventory != null, "Can't set inventory to null!")
        assert(inventory == null, "Inventory already set!")
        inventory = new_inventory
        if _weight_component != null:
            _weight_component.inventory = inventory
        if _stacks_component != null:
            _stacks_component.inventory = inventory
        if _grid_component != null:
            _grid_component.inventory = inventory
        inventory.item_added.connect(Callable(self, "_on_item_added"))
        inventory_set.emit()


enum Configuration {WSG, WS, WG, SG, W, S, G, VANILLA}


func _init(inventory_: Inventory) -> void:
    inventory = inventory_


func _on_item_added(item: InventoryItem) -> void:
    assert(_enforce_constraints(item), "Failed to enforce component constraints!")


func _enforce_constraints(item: InventoryItem) -> bool:
    match get_configuration():
        Configuration.G:
            return _grid_component.move_item_to_free_spot(item)
        Configuration.WG:
            return _grid_component.move_item_to_free_spot(item)
        Configuration.SG:
            if _grid_component.move_item_to_free_spot(item):
                return true
            return _stacks_component.pack_item(item)
        Configuration.WSG:
            if _grid_component.move_item_to_free_spot(item):
                return true
            return _stacks_component.pack_item(item)

    return true


func get_configuration() -> int:
    if _weight_component && _stacks_component && _grid_component:
        return Configuration.WSG

    if _weight_component && _stacks_component:
        return Configuration.WS

    if _weight_component && _grid_component:
        return Configuration.WG

    if _stacks_component && _grid_component:
        return Configuration.SG

    if _weight_component:
        return Configuration.W

    if _stacks_component:
        return Configuration.S

    if _grid_component:
        return Configuration.G

    return Configuration.VANILLA


func get_space_for(item: InventoryItem) -> ItemCount:
    match get_configuration():
        Configuration.W:
            return _weight_component.get_space_for(item)
        Configuration.S:
            return _stacks_component.get_space_for(item)
        Configuration.G:
            return _grid_component.get_space_for(item)
        Configuration.WS:
            return _ws_get_space_for(item)
        Configuration.WG:
            return ItemCount.min(_grid_component.get_space_for(item), _weight_component.get_space_for(item))
        Configuration.SG:
            return _sg_get_space_for(item)
        Configuration.WSG:
            return ItemCount.min(_sg_get_space_for(item), _ws_get_space_for(item))

    return ItemCount.inf()


func _ws_get_space_for(item: InventoryItem) -> ItemCount:
    var stack_size := ItemCount.new(_stacks_component.get_item_stack_size(item))
    var result := _weight_component.get_space_for(item).div(stack_size)
    return result


func _sg_get_space_for(item: InventoryItem) -> ItemCount:
    var grid_space := _grid_component.get_space_for(item)
    var max_stack_size := ItemCount.new(_stacks_component.get_item_max_stack_size(item))
    var stack_size := ItemCount.new(_stacks_component.get_item_stack_size(item))
    var free_stacks_space := _stacks_component.get_free_stack_space_for(item)
    return grid_space.mul(max_stack_size).add(free_stacks_space).div(stack_size)


func has_space_for(item: InventoryItem) -> bool:
    return not get_space_for(item).less(ItemCount.new(1))


func enable_weight_component_(capacity: float = 0.0) -> void:
    assert(_weight_component == null, "Weight component is already enabled")
    _weight_component = WeightComponent.new(inventory)
    _weight_component.capacity = capacity


func enable_stacks_component_() -> void:
    assert(_stacks_component == null, "Stacks component is already enabled")
    _stacks_component = StacksComponent.new(inventory)


func enable_grid_component_(size: Vector2i = GridComponent.DEFAULT_SIZE) -> void:
    assert(_grid_component == null, "Grid component is already enabled")
    _grid_component = GridComponent.new(inventory)
    _grid_component.size = size


func get_weight_component() -> WeightComponent:
    return _weight_component


func get_stacks_component() -> StacksComponent:
    return _stacks_component


func get_grid_component() -> GridComponent:
    return _grid_component


func reset() -> void:
    if get_weight_component():
        get_weight_component().reset()
    if get_stacks_component():
        get_stacks_component().reset()
    if get_grid_component():
        get_grid_component().reset()


func serialize() -> Dictionary:
    var result := {}

    if get_weight_component():
        result[KEY_WEIGHT_COMPONENT] = get_weight_component().serialize()
    if get_stacks_component():
        result[KEY_STACKS_COMPONENT] = get_stacks_component().serialize()
    if get_grid_component():
        result[KEY_GRID_COMPONENT] = get_grid_component().serialize()

    return result


func deserialize(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_WEIGHT_COMPONENT, TYPE_DICTIONARY):
        return false
    if !Verify.dict(source, false, KEY_STACKS_COMPONENT, TYPE_DICTIONARY):
        return false
    if !Verify.dict(source, false, KEY_GRID_COMPONENT, TYPE_DICTIONARY):
        return false

    reset()

    if source.has(KEY_WEIGHT_COMPONENT):
        if !get_weight_component().deserialize(source[KEY_WEIGHT_COMPONENT]):
            return false
    if source.has(KEY_STACKS_COMPONENT):
        if !get_stacks_component().deserialize(source[KEY_STACKS_COMPONENT]):
            return false
    if source.has(KEY_GRID_COMPONENT):
        if !get_grid_component().deserialize(source[KEY_GRID_COMPONENT]):
            return false

    return true
