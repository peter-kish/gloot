extends "res://addons/gloot/core/constraints/inventory_constraint.gd"

const WeightConstraint = preload("res://addons/gloot/core/constraints/weight_constraint.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

const KEY_STACK_SIZE: String = "stack_size"
const KEY_MAX_STACK_SIZE: String = "max_stack_size"

const DEFAULT_STACK_SIZE: int = 1
# TODO: Consider making the default max stack size 1
const DEFAULT_MAX_STACK_SIZE: int = 100

enum MergeResult {SUCCESS = 0, FAIL, PARTIAL}


# TODO: Check which util functions can be made private
# TODO: Consider making these util methods work with ItemCount
static func _get_free_stack_space(item: InventoryItem) -> int:
    assert(item != null, "item is null!")
    return get_item_max_stack_size(item) - get_item_stack_size(item)


static func _has_custom_property(item: InventoryItem, property: String, value) -> bool:
    assert(item != null, "item is null!")
    return item.properties.has(property) && item.properties[property] == value;


static func get_item_stack_size(item: InventoryItem) -> int:
    assert(item != null, "item is null!")
    return item.get_property(KEY_STACK_SIZE, DEFAULT_STACK_SIZE)


static func get_item_max_stack_size(item: InventoryItem) -> int:
    assert(item != null, "item is null!")
    return item.get_property(KEY_MAX_STACK_SIZE, DEFAULT_MAX_STACK_SIZE)


static func set_item_stack_size(item: InventoryItem, stack_size: int) -> bool:
    assert(item != null, "item is null!")
    assert(stack_size >= 0, "stack_size can't be negative!")
    if stack_size > get_item_max_stack_size(item):
        return false
    if stack_size == 0:
        var inventory: Inventory = item.get_inventory()
        if inventory != null:
            inventory.remove_item(item)
        item.queue_free()
        return true
    item.set_property(KEY_STACK_SIZE, stack_size)
    return true


static func set_item_max_stack_size(item: InventoryItem, max_stack_size: int) -> void:
    assert(item != null, "item is null!")
    assert(max_stack_size > 0, "max_stack_size can't be less than 1!")
    item.set_property(KEY_MAX_STACK_SIZE, max_stack_size)


static func get_prototype_stack_size(protoset: ItemProtoset, prototype_id: String) -> int:
    assert(protoset != null, "protoset is null!")
    return protoset.get_item_property(prototype_id, KEY_STACK_SIZE, 1.0)


static func get_prototype_max_stack_size(protoset: ItemProtoset, prototype_id: String) -> int:
    assert(protoset != null, "protoset is null!")
    return protoset.get_item_property(prototype_id, KEY_MAX_STACK_SIZE, 1.0)


func get_mergable_items(item: InventoryItem) -> Array[InventoryItem]:
    assert(inventory != null, "Inventory not set!")
    assert(item != null, "item is null!")

    var result: Array[InventoryItem] = []

    for i in inventory.get_items():
        if i == item:
            continue
        if !items_mergable(i, item):
            continue

        result.append(i)
            
    return result


static func items_mergable(item_1: InventoryItem, item_2: InventoryItem) -> bool:
    # Two item stacks are mergable if they have the same prototype ID and neither of the two contain
    # custom properties that the other one doesn't have (except for "stack_size", "max_stack_size",
    # "grid_position", or "weight").
    assert(item_1 != null, "item_1 is null!")
    assert(item_2 != null, "item_2 is null!")

    var ignore_properies: Array[String] = [
        KEY_STACK_SIZE,
        KEY_MAX_STACK_SIZE,
        GridConstraint.KEY_GRID_POSITION,
        WeightConstraint.KEY_WEIGHT
    ]

    if item_1.prototype_id != item_2.prototype_id:
        return false

    for property in item_1.properties.keys():
        if property in ignore_properies:
            continue
        if !_has_custom_property(item_2, property, item_1.properties[property]):
            return false

    for property in item_2.properties.keys():
        if property in ignore_properies:
            continue
        if !_has_custom_property(item_1, property, item_2.properties[property]):
            return false

    return true


func add_item_automerge(
    item: InventoryItem,
    ignore_properies: Array[String] = []
) -> bool:
    assert(item != null, "Item is null!")
    assert(inventory != null, "Inventory not set!")
    if !inventory._constraint_manager.has_space_for(item):
        return false

    var target_items = get_mergable_items(item)
    for target_item in target_items:
        if _merge_stacks(target_item, item) == MergeResult.SUCCESS:
            return true

    assert(inventory.add_item(item))
    return true


static func _merge_stacks(item_dst: InventoryItem, item_src: InventoryItem) -> int:
    assert(item_dst != null, "item_dst is null!")
    assert(item_src != null, "item_src is null!")

    var src_size: int = get_item_stack_size(item_src)
    assert(src_size > 0, "Item stack size must be greater than 0!")

    var dst_size: int = get_item_stack_size(item_dst)
    var dst_max_size: int = get_item_max_stack_size(item_dst)
    var free_dst_stack_space: int = dst_max_size - dst_size
    if free_dst_stack_space <= 0:
        return MergeResult.FAIL

    assert(set_item_stack_size(item_src, max(src_size - free_dst_stack_space, 0)))
    assert(set_item_stack_size(item_dst, min(dst_size + src_size, dst_max_size)))

    if free_dst_stack_space >= src_size:
        return MergeResult.SUCCESS

    return MergeResult.PARTIAL


static func split_stack(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    assert(item != null, "item is null!")
    assert(new_stack_size >= 1, "New stack size must be greater or equal to 1!")

    var stack_size = get_item_stack_size(item)
    assert(stack_size > 1, "Size of the item stack must be greater than 1!")
    assert(
        new_stack_size < stack_size,
        "New stack size must be smaller than the original stack size!"
    )

    var new_item = item.duplicate()
    if new_item.get_parent():
        new_item.get_parent().remove_child(new_item)

    assert(set_item_stack_size(new_item, new_stack_size))
    assert(set_item_stack_size(item, stack_size - new_stack_size))
    return new_item


# TODO: Rename this
func split_stack_safe(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    assert(inventory != null, "inventory is null!")
    assert(inventory.has_item(item), "The inventory does not contain the given item!")

    var new_item = split_stack(item, new_stack_size)
    if new_item:
        assert(inventory.add_item(new_item))
    return new_item


func join_stacks(
    item_dst: InventoryItem,
    item_src: InventoryItem
) -> bool:
    if (!stacks_joinable(item_dst, item_src)):
        return false

    # TODO: Check if this can be an assertion
    _merge_stacks(item_dst, item_src)
    return true


func stacks_joinable(
    item_dst: InventoryItem,
    item_src: InventoryItem
) -> bool:
    assert(inventory != null, "inventory is null!")
    assert(item_dst != null, "item_dst is null!")
    assert(item_src != null, "item_src is null!")

    if not items_mergable(item_dst, item_src):
        return false

    var dst_free_space = _get_free_stack_space(item_dst)
    if dst_free_space < get_item_stack_size(item_src):
        return false

    return true


func get_space_for(item: InventoryItem) -> ItemCount:
    return ItemCount.inf()


func get_free_stack_space_for(item: InventoryItem) -> ItemCount:
    assert(inventory != null, "Inventory not set!")

    var item_count = ItemCount.zero()
    var mergable_items = get_mergable_items(item)
    for mergable_item in mergable_items:
        var free_stack_space := _get_free_stack_space(mergable_item)
        item_count.add(ItemCount.new(free_stack_space))
    return item_count


func pack_item(item: InventoryItem) -> void:
    var free_stack_space := get_free_stack_space_for(item)
    if free_stack_space.eq(ItemCount.zero()):
        return
    var stacks_size := ItemCount.new(get_item_stack_size(item))
    if stacks_size.gt(free_stack_space):
        item = split_stack(item, free_stack_space.count)

    var mergable_items = get_mergable_items(item)
    for mergable_item in mergable_items:
        var merge_result := _merge_stacks(mergable_item, item)
        if merge_result == MergeResult.SUCCESS:
            return


func transfer_autosplit(item: InventoryItem, destination: Inventory) -> InventoryItem:
    assert(inventory._constraint_manager.get_configuration() == destination._constraint_manager.get_configuration())
    if inventory.transfer(item, destination):
        return item

    var stack_size := get_item_stack_size(item)
    if stack_size <= 1:
        return null

    var item_count := _get_space_for_single_item(destination, item)
    assert(!item_count.eq(ItemCount.inf()), "Item count shouldn't be infinite!")
    var count = item_count.count

    if count <= 0:
        return null

    var new_item: InventoryItem = split_stack(item, count)
    assert(new_item != null)
    assert(destination.add_item(new_item))
    return new_item


func _get_space_for_single_item(inventory: Inventory, item: InventoryItem) -> ItemCount:
    var single_item := item.duplicate()
    assert(set_item_stack_size(single_item, 1))
    var count := inventory._constraint_manager.get_space_for(single_item)
    single_item.free()
    return count


func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    assert(inventory._constraint_manager.get_configuration() == destination._constraint_manager.get_configuration())
    var new_item := transfer_autosplit(item, destination)
    if new_item:
        # Item could have been packed already
        # TODO: Find a more elegant way of handling this
        if new_item.is_queued_for_deletion():
            return true
        destination._constraint_manager.get_stacks_constraint().pack_item(new_item)
        return true
    return false


func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
    assert(inventory._constraint_manager.get_configuration() == destination._constraint_manager.get_configuration())
    if inventory.transfer(item, destination):
        # Item could have been packed already
        # TODO: Find a more elegant way of handling this
        if item.is_queued_for_deletion():
            return true
        destination._constraint_manager.get_stacks_constraint().pack_item(item)
        return true
    return false

