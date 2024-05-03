const KEY_STACK_SIZE: String = "stack_size"
const KEY_MAX_STACK_SIZE: String = "max_stack_size"

const DEFAULT_STACK_SIZE: int = 1
const DEFAULT_MAX_STACK_SIZE: int = 1


static func get_item_stack_size(item: InventoryItem) -> ItemCount:
    assert(item != null, "item is null!")
    var stack_size: int = item.get_property(KEY_STACK_SIZE, DEFAULT_STACK_SIZE)
    return ItemCount.new(stack_size)


static func get_item_max_stack_size(item: InventoryItem) -> ItemCount:
    assert(item != null, "item is null!")
    var max_stack_size: int = item.get_property(KEY_MAX_STACK_SIZE, DEFAULT_MAX_STACK_SIZE)
    return ItemCount.new(max_stack_size)


static func set_item_stack_size(item: InventoryItem, stack_size: ItemCount) -> bool:
    assert(item != null, "item is null!")
    assert(stack_size != null, "stack_size is null!")
    if stack_size.gt(get_item_max_stack_size(item)):
        return false
    if stack_size.eq(ItemCount.new(0)):
        var inventory: Inventory = item.get_inventory()
        if inventory != null:
            inventory.remove_item(item)
    item.set_property(KEY_STACK_SIZE, stack_size.count)
    return true


static func set_item_max_stack_size(item: InventoryItem, max_stack_size: ItemCount) -> void:
    assert(item != null, "item is null!")
    assert(max_stack_size != null, "max_stack_size is null!")
    item.set_property(KEY_MAX_STACK_SIZE, max_stack_size.count)


static func get_prototype_stack_size(prototree: ProtoTree, prototype_path: String) -> ItemCount:
    assert(prototree != null, "prototree is null!")
    var stack_size: int = prototree.get_prototype_property(prototype_path, KEY_STACK_SIZE, DEFAULT_STACK_SIZE)
    return ItemCount.new(stack_size)


static func get_prototype_max_stack_size(prototree: ProtoTree, prototype_path: String) -> ItemCount:
    assert(prototree != null, "prototree is null!")
    var max_stack_size: int = prototree.get_prototype_property(prototype_path, KEY_MAX_STACK_SIZE, DEFAULT_MAX_STACK_SIZE)
    return ItemCount.new(max_stack_size)


static func _stacks_compatible(item_1: InventoryItem, item_2: InventoryItem) -> bool:
    # Two item stacks are compatible for mergine if they have the same prototype and neither of the two contain
    # overridden properties that the other one doesn't have (except for "stack_size", "max_stack_size").
    assert(item_1 != null, "item_1 is null!")
    assert(item_2 != null, "item_2 is null!")

    var ignore_properies: Array[String] = [
        KEY_STACK_SIZE,
        KEY_MAX_STACK_SIZE
    ]

    if !item_1.get_prototype().get_path().equal(item_2.get_prototype().get_path()):
        return false

    for property in item_1.get_overridden_properties():
        if property in ignore_properies:
            continue
        if !item_2.is_property_overridden(property) || item_2.get_property(property) != item_1.get_property(property):
            return false

    for property in item_2.get_overridden_properties():
        if property in ignore_properies:
            continue
        if !item_1.is_property_overridden(property) || item_1.get_property(property) != item_2.get_property(property):
            return false

    return true


static func merge_stacks(item_dst: InventoryItem, item_src: InventoryItem, split_source: bool = false) -> bool:
    if split_source:
        return _merge_stacks_split_source(item_dst, item_src)
    return _merge_stacks(item_dst, item_src)


static func can_merge_stacks(item_dst: InventoryItem, item_src: InventoryItem, split_source: bool = false) -> bool:
    if split_source:
        return _can_merge_stacks_split_source(item_dst, item_src)
    return _can_merge_stacks(item_dst, item_src)


static func _merge_stacks(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    assert(item_dst != null, "item_dst is null!")
    assert(item_src != null, "item_src is null!")

    if !_can_merge_stacks(item_dst, item_src):
        return false

    var src_size := get_item_stack_size(item_src)
    set_item_stack_size(item_src, ItemCount.zero())
    set_item_stack_size(item_dst, get_item_stack_size(item_dst).add(src_size))
    return true


static func _can_merge_stacks(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    if !_stacks_compatible(item_dst, item_src):
        return false

    var src_size: ItemCount = get_item_stack_size(item_src)
    var dst_size := get_item_stack_size(item_dst)
    var free_dst_stack_space := get_free_stack_space(item_dst)

    if free_dst_stack_space.eq(ItemCount.zero()):
        return false
    if src_size.gt(free_dst_stack_space):
        return false
    return true


static func _merge_stacks_split_source(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    assert(item_dst != null, "item_dst is null!")
    assert(item_src != null, "item_src is null!")

    if !_stacks_compatible(item_dst, item_src):
        return false
    if !_can_merge_stacks_split_source(item_dst, item_src):
        return false
    if _merge_stacks(item_dst, item_src):
        return true

    var free_dst_stack_space := get_free_stack_space(item_dst)
    var new_stack := split_stack(item_src, free_dst_stack_space)
    assert(_merge_stacks(item_dst, new_stack))
    return true


static func _can_merge_stacks_split_source(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    assert(item_dst != null, "item_dst is null!")
    assert(item_src != null, "item_src is null!")
    return !get_free_stack_space(item_dst).eq(ItemCount.zero())


static func get_free_stack_space(item: InventoryItem) -> ItemCount:
    assert(item != null, "item is null!")
    return get_item_max_stack_size(item).sub(get_item_stack_size(item))


static func split_stack(item: InventoryItem, new_stack_size: ItemCount) -> InventoryItem:
    if !can_split_stack(item, new_stack_size):
        return null

    var new_item := item.duplicate()
    set_item_stack_size(item, get_item_stack_size(item).sub(new_stack_size))
    set_item_stack_size(new_item, new_stack_size)
    return new_item


static func can_split_stack(item: InventoryItem, new_stack_size: ItemCount) -> bool:
    if get_item_stack_size(item).gt(new_stack_size):
        return true
    return false


static func inv_split_stack(inv: Inventory, item: InventoryItem, new_stack_size: ItemCount) -> InventoryItem:
    assert(inv.has_item(item), "Inventory must contain item!")

    var old_item_stack_size := get_item_stack_size(item)
    var new_stack := split_stack(item, new_stack_size)
    if new_stack == null:
        return null

    if !inv.add_item(new_stack):
        set_item_stack_size(item, old_item_stack_size)
        return null
    
    return new_stack


static func inv_merge_stack(inv: Inventory, item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    assert(inv.has_item(item_dst), "Inventory must contain item_dst!")

    if !inv.has_item(item_src) && !inv.can_add_item(item_src):
        return false

    if !merge_stacks(item_dst, item_src):
        return false

    var inv_src := item_src.get_inventory()
    if is_instance_valid(inv_src):
        inv_src.remove_item(item_src)
    return true


static func inv_add_automerge(inv: Inventory, item: InventoryItem) -> bool:
    assert(!inv.has_item(item), "Inventory must not contain item!")

    for i in inv.get_items():
        if inv_merge_stack(inv, i, item):
            return true
    return inv.add_item(item)


static func inv_add_autosplitmerge(inv: Inventory, item: InventoryItem) -> bool:
    assert(!inv.has_item(item), "Inventory must not contain item!")
    
    var space_for_item := inv._constraint_manager.get_space_for(item)
    if space_for_item.eq(ItemCount.zero()):
        return false

    if inv_add_automerge(inv, item):
        return true

    var partial_stack = split_stack(item, space_for_item)
    assert(get_item_stack_size(item).gt(ItemCount.zero()))
    for i in inv.get_items():
        merge_stacks(i, partial_stack, true)
        if get_item_stack_size(partial_stack).eq(ItemCount.zero()):
            return true

    assert(inv.add_item(partial_stack))
    return true


