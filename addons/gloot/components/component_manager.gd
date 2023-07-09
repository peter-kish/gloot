class_name ComponentManager

signal inventory_set

var weight_component_: WeightComponent = null
var stacks_component_: StacksComponent = null
var grid_component_: GridComponent = null
var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        assert(new_inventory != null, "Can't set inventory to null!")
        assert(inventory == null, "Inventory already set!")
        inventory = new_inventory
        if weight_component_ != null:
            weight_component_.inventory = inventory
        if stacks_component_ != null:
            stacks_component_.inventory = inventory
        if grid_component_ != null:
            grid_component_.inventory = inventory
        inventory_set.emit()


enum Configuration {WSG, WS, WG, SG, W, S, G, VANILLA}


func get_configuration() -> int:
    if weight_component_ && stacks_component_ && grid_component_:
        return Configuration.WSG

    if weight_component_ && stacks_component_:
        return Configuration.WS

    if weight_component_ && grid_component_:
        return Configuration.WG

    if stacks_component_ && grid_component_:
        return Configuration.SG

    if weight_component_:
        return Configuration.W

    if stacks_component_:
        return Configuration.S

    if grid_component_:
        return Configuration.G

    return Configuration.VANILLA


func get_space_for(item: InventoryItem) -> ItemCount:
    match get_configuration():
        Configuration.W:
            return weight_component_.get_space_for(item)
        Configuration.S:
            return stacks_component_.get_space_for(item)
        Configuration.G:
            return grid_component_.get_space_for(item)
        Configuration.WS:
            return _ws_get_space_for(item)
        Configuration.WG:
            return ItemCount.min(grid_component_.get_space_for(item), weight_component_.get_space_for(item))
        Configuration.SG:
            return _sg_get_space_for(item)
        Configuration.WSG:
            return ItemCount.min(_sg_get_space_for(item), _ws_get_space_for(item))

    return ItemCount.new(ItemCount.Inf)


func _ws_get_space_for(item: InventoryItem) -> ItemCount:
    var stack_size := ItemCount.new(stacks_component_.get_item_stack_size(item))
    return weight_component_.get_space_for(item).div(stack_size)


func _sg_get_space_for(item: InventoryItem) -> ItemCount:
    var grid_space := grid_component_.get_space_for(item)
    var max_stack_size := ItemCount.new(stacks_component_.get_item_max_stack_size(item))
    var stack_size := ItemCount.new(stacks_component_.get_item_stack_size(item))
    var free_stacks_space := stacks_component_.get_free_stack_space_for(item)
    return grid_space.mul(max_stack_size).add(free_stacks_space).div(stack_size)


func has_space_for(item: InventoryItem) -> bool:
    return not get_space_for(item).less(ItemCount.new(1))


func enable_weight_component_(capacity: float = 0.0) -> void:
    assert(weight_component_ == null, "Weight component is already enabled")
    weight_component_ = WeightComponent.new()
    weight_component_.capacity = capacity
    weight_component_.inventory = inventory


func enable_stacks_component_() -> void:
    assert(grid_component_ == null, "Stacks component is already enabled")
    stacks_component_ = StacksComponent.new()
    stacks_component_.inventory = inventory


func enable_grid_component_(size: Vector2i = GridComponent.DEFAULT_SIZE) -> void:
    assert(grid_component_ == null, "Grid component is already enabled")
    grid_component_ = GridComponent.new()
    grid_component_.inventory = inventory
    grid_component_.size = size


func get_weight_component() -> WeightComponent:
    return weight_component_


func get_stacks_component() -> StacksComponent:
    return stacks_component_


func get_grid_component() -> GridComponent:
    return grid_component_
