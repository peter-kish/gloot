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
    if !has_place_for(item):
        return false

    ItemStackManager.add_item_automerge(self, item, [KEY_GRID_POSITION])
    return true
    
    
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
