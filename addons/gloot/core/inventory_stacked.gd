@tool
@icon("res://addons/gloot/images/icon_inventory_stacked.svg")
extends Inventory
class_name InventoryStacked

## Inventory that has a limited item capacity in terms of weight.

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")

## Emitted when the inventory capacity has changed.
signal capacity_changed
## Emitted when the amount of occupied space in the inventory has changed.
signal occupied_space_changed

## Maximum weight the inventory can hold.
## Set to 0.0 for unlimited capacity.
@export var capacity: float :
    get:
        if _constraint_manager == null:
            return 0.0
        if _constraint_manager.get_weight_constraint() == null:
            return 0.0
        return _constraint_manager.get_weight_constraint().capacity
    set(new_capacity):
        _constraint_manager.get_weight_constraint().capacity = new_capacity

## Currently occupied space in the inventory
var occupied_space: float :
    get:
        if _constraint_manager == null:
            return 0.0
        if _constraint_manager.get_weight_constraint() == null:
            return 0.0
        return _constraint_manager.get_weight_constraint().occupied_space
    set(new_occupied_space):
        push_error("occupied_space is read-only!")


func _init() -> void:
    super._init()
    _constraint_manager.enable_weight_constraint()
    _constraint_manager.enable_stacks_constraint()
    _constraint_manager.get_weight_constraint().capacity_changed.connect(func(): capacity_changed.emit())
    _constraint_manager.get_weight_constraint().occupied_space_changed.connect(func(): occupied_space_changed.emit())

## Checks if the inventory has unlimited capacity (i.e. capacity is 0.0).
func has_unlimited_capacity() -> bool:
    return _constraint_manager.get_weight_constraint().has_unlimited_capacity()

## Returns the free available space in the inventory.
func get_free_space() -> float:
    return _constraint_manager.get_weight_constraint().get_free_space()

## Checks if the inventory has enough free space for the given item.
func has_place_for(item: InventoryItem) -> bool:
    return _constraint_manager.has_space_for(item)

## Adds the given item stack to the inventory, automatically merging with
## existing item stacks with the same prototype ID.
func add_item_automerge(item: InventoryItem) -> bool:
    return _constraint_manager.get_stacks_constraint().add_item_automerge(item)

## Splits the given item stack into two. The newly created stack will have
## the size [param new_stack_size], while the old stack will contain
## the remainder.
func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return _constraint_manager.get_stacks_constraint().split_stack_safe(item, new_stack_size)

## Joins the [param item_src] item stack with the [param item_dst] stack.
static func join(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    return StacksConstraint.join_stacks(item_dst, item_src)

## Returns the stack size of the given item.
static func get_item_stack_size(item: InventoryItem) -> int:
    return StacksConstraint.get_item_stack_size(item)

## Sets the stack size of the given item. If the stack size is set to 0 the item
## will be removed from its directory and queued for deletion. If
## [param new_stack_size] is greater than the maximum stack size or negative,
## the stack size will remain unchanged and the function will return
## [code]false[/code].
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
    return StacksConstraint.get_prototype_stack_size(item_protoset, prototype_id)

## Returns the maximum stack size of the given item prototype.
func get_prototype_max_stack_size(prototype_id: String) -> int:
    return StacksConstraint.get_prototype_max_stack_size(item_protoset, prototype_id)

## Transfers the given item stack into the given inventory, splitting it if
## there is not enough space for the whole stack.
func transfer_autosplit(item: InventoryItem, destination: InventoryStacked) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_autosplit(item, destination) != null

## Transfers the given item stack into the given inventory, joining it with any
## available item stacks with the same prototype ID.
func transfer_automerge(item: InventoryItem, destination: InventoryStacked) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_automerge(item, destination)

## A combination of [method transfer_autosplit] and [method transfer_automerge].
## Transfers the given item stack into the given inventory, splitting it up and
## joining it with available item stacks, as needed.
func transfer_autosplitmerge(item: InventoryItem, destination: InventoryStacked) -> bool:
    return _constraint_manager.get_stacks_constraint().transfer_autosplitmerge(item, destination)

## Merges the given item with all compatible items in the same inventory.
static func pack(item: InventoryItem) -> void:
    return StacksConstraint.pack_item(item)
