@tool
extends InventoryGrid
class_name InventoryGridStacked

const ItemStackManager = preload("res://addons/gloot/item_stack_manager.gd")


func has_place_for(item: InventoryItem) -> bool:
    if _has_grid_space_for(item):
        return true

    if _has_stack_space_for(item):
        return true

    return false


func _has_grid_space_for(item: InventoryItem) -> bool:
    return Verify.vector_positive(find_free_place(item))


func _has_stack_space_for(item: InventoryItem) -> bool:
    return _get_stack_space_for(item) >= ItemStackManager.get_item_stack_size(item);


func _get_stack_space_for(item: InventoryItem) -> int:
    var mergable_items = ItemStackManager.get_mergable_items(self, item, [KEY_GRID_POSITION])
    var free_stack_space := 0
    for mergable_item in mergable_items:
        free_stack_space += ItemStackManager.get_free_stack_space(mergable_item)
    return free_stack_space
    

func add_item_automerge(item: InventoryItem) -> bool:
    # TODO: Eliminate duplicted code here and in inventory_stacked.gd
    if !has_place_for(item):
        return false

    var target_items = ItemStackManager.get_mergable_items(self, item)
    target_items.sort_custom(Callable(self, "_compare_items_by_stack_size"))
    for target_item in target_items:
        if ItemStackManager.merge_stacks(item, target_item) == ItemStackManager.MergeResult.SUCCESS:
            if item.get_inventory():
                item.get_inventory().remove_item(item)
            item.free()
            return true

    super.add_item(item)
    return true


func _compare_items_by_stack_size(a: InventoryItem, b: InventoryItem) -> bool:
    return ItemStackManager.get_item_stack_size(a) < ItemStackManager.get_item_stack_size(b)
    
    
func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    if !_has_grid_space_for(item):
        return null

    var new_item = ItemStackManager.split_stack(item, new_stack_size)
    assert(add_item(new_item))
    return new_item


func join(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    return ItemStackManager.join_stacks(self, item_src, item_dst, [KEY_GRID_POSITION])


func transfer_autosplit(item: InventoryItem, destination: Inventory) -> bool:
    assert(false, "Not implemented!")
    return false


func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
    assert(false, "Not implemented!")
    return false


func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    assert(false, "Not implemented!")
    return false
