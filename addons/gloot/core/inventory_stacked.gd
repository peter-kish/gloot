@tool
@icon("res://addons/gloot/images/icon_inventory_stacked.svg")
extends Inventory
class_name InventoryStacked

signal capacity_changed
signal occupied_space_changed

const StackManager = preload("res://addons/gloot/core/stack_manager.gd")

@export var capacity: float :
    get:
        if _constraint_manager == null || _constraint_manager.get_weight_constraint() == null:
            return 0.0
        return _constraint_manager.get_weight_constraint().capacity
    set(new_capacity):
        _constraint_manager.get_weight_constraint().capacity = new_capacity
var occupied_space: float :
    get:
        if _constraint_manager == null || _constraint_manager.get_weight_constraint() == null:
            return 0.0
        return _constraint_manager.get_weight_constraint().occupied_space
    set(new_occupied_space):
        assert(false, "occupied_space is read-only!")


func _init() -> void:
    super._init()
    _constraint_manager.enable_weight_constraint()
    _constraint_manager.get_weight_constraint().capacity_changed.connect(func(): capacity_changed.emit())
    _constraint_manager.get_weight_constraint().occupied_space_changed.connect(func(): occupied_space_changed.emit())


func has_unlimited_capacity() -> bool:
    return _constraint_manager.get_weight_constraint().has_unlimited_capacity()


func get_free_space() -> float:
    return _constraint_manager.get_weight_constraint().get_free_space()


func has_place_for(item: InventoryItem) -> bool:
    return _constraint_manager.has_space_for(item)


func add_item_automerge(item: InventoryItem) -> bool:
    return StackManager.inv_add_automerge(self, item)


func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return StackManager.inv_split_stack(self, item, ItemCount.new(new_stack_size))


static func join(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    return StackManager.merge_stacks(item_dst, item_src)


static func get_item_stack_size(item: InventoryItem) -> int:
    return StackManager.get_item_stack_size(item).count


static func set_item_stack_size(item: InventoryItem, new_stack_size: int) -> bool:
    return StackManager.set_item_stack_size(item, ItemCount.new(new_stack_size))


static func get_item_max_stack_size(item: InventoryItem) -> int:
    return StackManager.get_item_max_stack_size(item).count


static func set_item_max_stack_size(item: InventoryItem, new_stack_size: int) -> void:
    StackManager.set_item_max_stack_size(item, ItemCount.new(new_stack_size))


func get_prototype_stack_size(prototype_path: String) -> int:
    return StackManager.get_prototype_stack_size(_prototree, prototype_path).count


func get_prototype_max_stack_size(prototype_path: String) -> int:
    return StackManager.get_prototype_max_stack_size(_prototree, prototype_path).count


# func transfer_autosplit(item: InventoryItem, destination: InventoryStacked) -> bool:
#     # TODO: Implement
#     return false


func transfer_automerge(item: InventoryItem, destination: InventoryStacked) -> bool:
    return StackManager.inv_add_automerge(destination, item)


func transfer_autosplitmerge(item: InventoryItem, destination: InventoryStacked) -> bool:
    return StackManager.inv_add_autosplitmerge(destination, item)


func reset() -> void:
    super.reset()
    _constraint_manager.enable_weight_constraint()
    _constraint_manager.get_weight_constraint().capacity_changed.connect(func(): capacity_changed.emit())
    _constraint_manager.get_weight_constraint().occupied_space_changed.connect(func(): occupied_space_changed.emit())
