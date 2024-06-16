@tool
@icon("res://addons/gloot/images/icon_inventory_grid_stacked.svg")
extends InventoryGrid
class_name InventoryGridStacked

## Grid based inventory that supports item stacks.

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")


func _init() -> void:
    super._init()
    _constraint_manager.enable_stacks_constraint()

## Checks if the inventory has enough free space for the given item.
func has_place_for(item: InventoryItem) -> bool:
    return _constraint_manager.has_space_for(item)

## Adds the given item stack to the inventory, automatically merging the
## existing item stacks with the same property ID.
func add_item_automerge(item: InventoryItem) -> bool:
    return _constraint_manager.get_stacks_constraint().add_item_automerge(item)

## Splits the given item stack into two. The newly created stack will have the
## size [param new_stack_size], while the old stack will contain the remainder.
func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return _constraint_manager.get_stacks_constraint().split_stack_safe(item, new_stack_size)

## Joins the [param item_src] item stack with the [param item_dst] stack.
func join(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    return _constraint_manager.get_stacks_constraint().join_stacks(item_dst, item_src)

## Returns the stack size of the given item.
static func get_item_stack_size(item: InventoryItem) -> int:
    return StacksConstraint.get_item_stack_size(item)

## Sets the stack size of the given item.
## If the stack size is set to 0 the item will be removed from its directory
## and queued for deletion. If [param new_stack_size] is greater than the
## maximum stack size or negative, the stack size will remained unchanged
## and the function will return [code]false[/code].
static func set_item_stack_size(item: InventoryItem, new_stack_size: int) -> bool:
    return StacksConstraint.set_item_stack_size(item, new_stack_size)

## Returns the maximum stack size for the given item.
static func get_item_max_stack_size(item: InventoryItem) -> int:
    return StacksConstraint.get_item_max_stack_size(item)

## Sets the maximum stack size for the given item.
static func set_item_max_stack_size(item: InventoryItem, new_stack_size: int) -> void:
    StacksConstraint.set_item_max_stack_size(item, new_stack_size)

## Returns the stack size of the given item prototype.
func get_prototype_stack_size(prototype_id: String) -> int:
    return _constraint_manager.get_stacks_constraint().get_prototype_stack_size(item_protoset, prototype_id)

## Returns the maximum stack size of the given item prototype.
func get_prototype_max_stack_size(prototype_id: String) -> int:
    return _constraint_manager.get_stacks_constraint().get_prototype_max_stack_size(item_protoset, prototype_id)

## Transfers the given item stack into the given inventory, joining it with any available item
## stacks with the same prototype ID.
func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_automerge(item, destination)

## Transfers the given item stack into the given inventory, splitting it up
## and joining it with available item stacks, as needed.
func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_autosplitmerge(item, destination)

## Merges the given item with all compatible items in the same inventory.
static func pack(item: InventoryItem) -> void:
    return StacksConstraint.pack_item(item)


func transfer_to(item: InventoryItem, destination: Inventory, position: Vector2i) -> bool:
    return _constraint_manager.get_grid_constraint().transfer_to(item, destination._constraint_manager.get_grid_constraint(), position)


func _get_mergable_item_at(item: InventoryItem, position: Vector2i) -> InventoryItem:
    return _constraint_manager.get_grid_constraint()._get_mergable_item_at(item, position)

