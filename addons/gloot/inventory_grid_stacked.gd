@tool
extends InventoryGrid
class_name InventoryGridStacked

const ItemStackManager = preload("res://addons/gloot/item_stack_manager.gd")


func has_place_for(item: InventoryItem) -> bool:
    # Check if there's place on the grid
    var free_place := find_free_place(item)
    if Verify.vector_positive(free_place):
        return true

    # Check if there's place in the existing item stacks
    var mergable_items = ItemStackManager.get_mergable_items(self, item, [KEY_GRID_POSITION])
    var free_stack_space := 0
    for mergable_item in mergable_items:
        free_stack_space += ItemStackManager.get_free_stack_space(mergable_item)

    if free_stack_space < ItemStackManager.get_item_stack_size(item):
        return false

    return true
    

func add_item_automerge(item: InventoryItem) -> bool:
    assert(false, "Not implemented!")
    return false
    
    
func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    assert(false, "Not implemented!")
    return null


func join(stack_1: InventoryItem, stack_2: InventoryItem) -> bool:
    assert(false, "Not implemented!")
    return false


func transfer_autosplit(item: InventoryItem, destination: Inventory) -> bool:
    assert(false, "Not implemented!")
    return false


func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
    assert(false, "Not implemented!")
    return false


func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    assert(false, "Not implemented!")
    return false
