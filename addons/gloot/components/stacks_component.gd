class_name StacksComponent
extends InventoryComponent

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


static func set_item_stack_size(item: InventoryItem, stack_size: int) -> void:
    assert(item != null, "item is null!")
    item.set_property(KEY_STACK_SIZE, stack_size)


static func set_item_max_stack_size(item: InventoryItem, max_stack_size: int) -> void:
    assert(item != null, "item is null!")
    item.set_property(KEY_MAX_STACK_SIZE, max_stack_size)


static func get_prototype_stack_size(protoset: ItemProtoset, prototype_id: String) -> int:
    assert(protoset != null, "protoset is null!")
    return protoset.get_item_property(prototype_id, KEY_STACK_SIZE, 1.0)


static func get_prototype_max_stack_size(protoset: ItemProtoset, prototype_id: String) -> int:
    assert(protoset != null, "protoset is null!")
    return protoset.get_item_property(prototype_id, KEY_MAX_STACK_SIZE, 1.0)


func get_mergable_items(
    item: InventoryItem
) -> Array[InventoryItem]:
    assert(inventory != null, "Inventory not set!")
    assert(item != null, "item is null!")

    var result: Array[InventoryItem] = []

    for i in inventory.get_items():
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
        GridComponent.KEY_GRID_POSITION,
        WeightComponent.KEY_WEIGHT
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
) -> void:
    assert(item != null, "Item is null!")
    assert(inventory != null, "Inventory not set!")

    var target_items = get_mergable_items(item)
    for target_item in target_items:
        if _merge_stacks_autodelete(target_item, item) == MergeResult.SUCCESS:
            return

    inventory.add_item(item)


static func _merge_stacks_autodelete(item_dst: InventoryItem, item_src: InventoryItem) -> int:
    var result := _merge_stacks(item_dst, item_src)
    if result == MergeResult.SUCCESS:
        if item_src.get_inventory():
            item_src.get_inventory().remove_item(item_src)
        item_src.queue_free()
    return result


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

    set_item_stack_size(item_dst, min(dst_size + src_size, dst_max_size))
    set_item_stack_size(item_src, max(src_size - free_dst_stack_space, 0))

    if free_dst_stack_space >= src_size:
        return MergeResult.SUCCESS

    return MergeResult.PARTIAL


static func split_stack(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    assert(item != null, "item is null!")
    assert(new_stack_size >= 1, "New stack size must be greater or equal to 1!")

    var stack_size = get_item_stack_size(item)
    assert(
        new_stack_size < stack_size,
        "New stack size must be smaller than the original stack size!"
    )

    var new_item = item.duplicate()
    set_item_stack_size(new_item, new_stack_size)
    set_item_stack_size(item, stack_size - new_stack_size)
    return new_item


func join_stacks(
    item_dst: InventoryItem,
    item_src: InventoryItem
) -> bool:
    if (!stacks_joinable(item_dst, item_src)):
        return false

    # TODO: Check if this can be an assertion
    _merge_stacks_autodelete(item_dst, item_src)
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
    return ItemCount.new(ItemCount.Inf)


func get_free_stack_space_for(item: InventoryItem) -> ItemCount:
    assert(inventory != null, "Inventory not set!")

    var item_count = ItemCount.new(0)
    var mergable_items = get_mergable_items(item)
    for mergable_item in mergable_items:
        var free_stack_space := _get_free_stack_space(mergable_item)
        item_count.add(ItemCount.new(free_stack_space))
    return item_count


func pack_item(item: InventoryItem) -> bool:
    var free_stack_space := get_free_stack_space_for(item)
    var stacks_size := ItemCount.new(get_item_stack_size(item))
    if stacks_size.gt(free_stack_space):
        return false

    var mergable_items = get_mergable_items(item)
    for mergable_item in mergable_items:
        if _merge_stacks_autodelete(mergable_item, item) == MergeResult.SUCCESS:
            return true

    # TODO: Make sure the inventory is unchanged when returning false
    return false
