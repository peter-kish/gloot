@tool
extends InventoryGrid
class_name InventoryGridStacked


func _init() -> void:
    super._init()
    _constraint_manager.enable_stacks_constraint_()


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


static func set_item_stack_size(item: InventoryItem, new_stack_size: int) -> void:
    StacksConstraint.set_item_stack_size(item, new_stack_size)


static func get_item_max_stack_size(item: InventoryItem) -> int:
    return StacksConstraint.get_item_max_stack_size(item)


static func set_item_max_stack_size(item: InventoryItem, new_stack_size: int) -> void:
    StacksConstraint.set_item_max_stack_size(item, new_stack_size)


func get_prototype_stack_size(prototype_id: String) -> int:
    return _constraint_manager.get_stacks_constraint().get_prototype_stack_size(item_protoset, prototype_id)


func get_prototype_max_stack_size(prototype_id: String) -> int:
    return _constraint_manager.get_stacks_constraint().get_prototype_max_stack_size(item_protoset, prototype_id)


func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_automerge(item, destination)


func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_autosplitmerge(item, destination)


func transfer_to(item: InventoryItem, destination: Inventory, position: Vector2i) -> bool:
    return _constraint_manager.get_grid_constraint().transfer_to(item, destination._constraint_manager.get_grid_constraint(), position)


func _get_mergable_item_at(item: InventoryItem, position: Vector2i) -> InventoryItem:
    return _constraint_manager.get_grid_constraint()._get_mergable_item_at(item, position)

