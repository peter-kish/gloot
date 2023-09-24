@tool
extends Inventory
class_name InventoryStacked

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")

signal capacity_changed
signal occupied_space_changed

@export var capacity: float :
    get:
        return _constraint_manager.get_weight_constraint().capacity
    set(new_capacity):
        _constraint_manager.get_weight_constraint().capacity = new_capacity
var occupied_space: float :
    get:
        return _constraint_manager.get_weight_constraint().occupied_space
    set(new_occupied_space):
        assert(false, "occupied_space is read-only!")


func _init() -> void:
    super._init()
    _constraint_manager.enable_weight_constraint_()
    _constraint_manager.enable_stacks_constraint_()
    _constraint_manager.get_weight_constraint().capacity_changed.connect(Callable(self, "_on_capacity_changed"))
    _constraint_manager.get_weight_constraint().occupied_space_changed.connect(Callable(self, "_on_occupied_space_changed"))


func _on_capacity_changed() -> void:
    capacity_changed.emit()


func _on_occupied_space_changed() -> void:
    occupied_space_changed.emit()


func has_unlimited_capacity() -> bool:
    return _constraint_manager.get_weight_constraint().has_unlimited_capacity()


func get_free_space() -> float:
    return _constraint_manager.get_weight_constraint().get_free_space()


func has_place_for(item: InventoryItem) -> bool:
    return _constraint_manager.has_space_for(item)


func add_item_automerge(item: InventoryItem) -> bool:
    return _constraint_manager.get_stacks_constraint().add_item_automerge(item)


func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return _constraint_manager.get_stacks_constraint().split_stack_safe(item, new_stack_size)


func join(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    return _constraint_manager.get_stacks_constraint().join_stacks(item_dst, item_src)


static func get_item_stack_size(item: InventoryItem) -> int:
    return StacksConstraint.get_item_stack_size(item)


static func set_item_stack_size(item: InventoryItem, new_stack_size: int) -> bool:
    return StacksConstraint.set_item_stack_size(item, new_stack_size)


static func get_item_max_stack_size(item: InventoryItem) -> int:
    return StacksConstraint.get_item_max_stack_size(item)


static func set_item_max_stack_size(item: InventoryItem, new_stack_size: int) -> void:
    StacksConstraint.set_item_max_stack_size(item, new_stack_size)


func get_prototype_stack_size(prototype_id: String) -> int:
    return StacksConstraint.get_prototype_stack_size(item_protoset, prototype_id)


func get_prototype_max_stack_size(prototype_id: String) -> int:
    return StacksConstraint.get_prototype_max_stack_size(item_protoset, prototype_id)


func transfer_autosplit(item: InventoryItem, destination: InventoryStacked) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_autosplit(item, destination) != null


func transfer_automerge(item: InventoryItem, destination: InventoryStacked) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_automerge(item, destination)


func transfer_autosplitmerge(item: InventoryItem, destination: InventoryStacked) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_autosplitmerge(item, destination)
