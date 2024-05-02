@tool
@icon("res://addons/gloot/images/icon_inventory_grid_stacked.svg")
extends InventoryGrid
class_name InventoryGridStacked

const StackManager = preload("res://addons/gloot/core/stack_manager.gd")


func has_place_for(item: InventoryItem) -> bool:
    return _constraint_manager.has_space_for(item)


# func add_item_automerge(item: InventoryItem) -> bool:
#     # TODO: Implement
#     return false
    
    
func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return StackManager.inv_split_stack(self, item, ItemCount.new(new_stack_size))


func join(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    return StackManager.inv_merge_stack(self, item_dst, item_src)


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


# func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
#     # TODO: Implement
#     return false


# func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
#     # TODO: Implement
#     return false


func transfer_to(item: InventoryItem, destination: Inventory, position: Vector2i) -> bool:
    return _constraint_manager.get_grid_constraint().transfer_to(item, destination.get_grid_constraint(), position)


func _get_mergable_item_at(item: InventoryItem, position: Vector2i) -> InventoryItem:
    var target_item := _constraint_manager.get_grid_constraint().get_item_at(position)
    if StackManager.can_merge_stacks(target_item, item):
        return target_item
    return null

