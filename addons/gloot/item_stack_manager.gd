const KEY_STACK_SIZE: String = "stack_size"
const KEY_MAX_STACK_SIZE: String = "max_stack_size"

const DEFAULT_STACK_SIZE: int = 1
# TODO: Consider making the default max stack size 1
const DEFAULT_MAX_STACK_SIZE: int = 100

enum MergeResult {SUCCESS = 0, FAIL, PARTIAL}


static func get_mergable_items(
    inventory: Inventory,
    item: InventoryItem,
    ignore_properies: Array[String] = []
) -> Array[InventoryItem]:
    assert(inventory != null, "inventory is null!")
    assert(item != null, "item is null!")

    var result: Array[InventoryItem] = []

    for i in inventory.get_items():
        if !items_mergable(i, item, ignore_properies):
            continue

        result.append(i)
            
    return result


static func items_mergable(item_1:
    InventoryItem, item_2:
    InventoryItem, ignore_properies: Array[String] = []
) -> bool:
    # Two item stacks are mergable if they have the same prototype ID and neither of the two contain
    # custom properties that the other one doesn't have (except for "stack_size", "max_stack_size"
    # or any of the ignore_properties).
    assert(item_1 != null, "item_1 is null!")
    assert(item_2 != null, "item_2 is null!")

    if item_1.prototype_id != item_2.prototype_id:
        return false

    for property in item_1.properties.keys():
        if property in ignore_properies:
            continue
        if property == KEY_STACK_SIZE || property == KEY_MAX_STACK_SIZE:
            continue
        if !has_custom_property(item_2, property, item_1.properties[property]):
            return false

    for property in item_2.properties.keys():
        if property in ignore_properies:
            continue
        if property == KEY_STACK_SIZE || property == KEY_MAX_STACK_SIZE:
            continue
        if !has_custom_property(item_1, property, item_2.properties[property]):
            return false

    return true


static func get_free_stack_space(item: InventoryItem) -> int:
    assert(item != null, "item is null!")
    return get_item_max_stack_size(item) - get_item_stack_size(item)


static func has_custom_property(item: InventoryItem, property: String, value) -> bool:
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


static func add_item_automerge(
    inventory: Inventory,
    item: InventoryItem,
    ignore_properies: Array[String] = []
) -> void:
    assert(item != null, "item is null!")
    assert(inventory != null, "inventory is null!")

    var target_items = get_mergable_items(inventory, item, ignore_properies)

    # TODO: Check if this sort is necessary
    var compare_stack_size = func (a: InventoryItem, b: InventoryItem) -> bool:
        return get_item_stack_size(a) < get_item_stack_size(b)
    target_items.sort_custom(compare_stack_size)

    for target_item in target_items:
        if merge_stacks_autodelete(target_item, item) == MergeResult.SUCCESS:
            return

    inventory.add_item(item)


static func merge_stacks_autodelete(item_dst: InventoryItem, item_src: InventoryItem) -> int:
    var result := merge_stacks(item_dst, item_src)
    if result == MergeResult.SUCCESS:
        if item_src.get_inventory():
            item_src.get_inventory().remove_item(item_src)
        item_src.free()
    return result


static func merge_stacks(item_dst: InventoryItem, item_src: InventoryItem) -> int:
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


static func join_stacks(
    inventory: Inventory,
    item_dst: InventoryItem,
    item_src: InventoryItem,
    ignore_properies: Array[String] = []
) -> bool:
    if (!stacks_joinable(inventory, item_dst, item_src, ignore_properies)):
        return false

    # TODO: Check if this can be an assertion
    merge_stacks_autodelete(item_dst, item_src)
    return true


static func stacks_joinable(
    inventory: Inventory,
    item_dst: InventoryItem,
    item_src: InventoryItem,
    ignore_properies: Array[String] = []
) -> bool:
    assert(inventory != null, "inventory is null!")
    assert(item_dst != null, "item_dst is null!")
    assert(item_src != null, "item_src is null!")

    if not items_mergable(item_dst, item_src, ignore_properies):
        return false

    var dst_free_space = get_free_stack_space(item_dst)
    if dst_free_space < get_item_stack_size(item_src):
        return false

    return true
