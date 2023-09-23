# `InventoryGridStacked`

Inherits: [`InventoryGrid`](./inventory_grid.md)

## Description

Grid based inventory that supports item stacks.

## Methods

* `static get_item_stack_size(item: InventoryItem) -> int` - Returns the stack size of the given item.
* `static set_item_stack_size(item: InventoryItem, new_stack_size: int) -> bool` - Sets the stack size of the given item. If the stack size is set to 0 the item will be removed from its directory and queued for deletion. If `new_stack_size` is greater than the maximum stack size or negative, the stack size will remain unchanged and the function will return `false`.
* `static get_item_max_stack_size(item: InventoryItem) -> int` - Returns the maximum stack size for the given item.
* `static set_item_max_stack_size(item: InventoryItem, new_stack_size: int) -> void` - Sets the maximum stack size for the given item.
* `get_prototype_stack_size(prototype_id: String) -> int` - Returns the stack size of the given item prototype.
* `get_prototype_max_stack_size(prototype_id: String) -> int` - Returns the maximum stack size of the given item prototype.
* `has_place_for(item: InventoryItem) -> bool` - Checks if the inventory has enough free space for the given item.
* `add_item_automerge(item: InventoryItem) -> bool` - Adds the given item stack to the inventory, automatically merging with existing item stacks with the same prototype ID.
* `split(item: InventoryItem, new_stack_size: int) -> InventoryItem` - Splits the given item stack into two. The newly created stack will have the size `new_stack_size`, while the old stack will contain the remainder.
* `join(item_dst: InventoryItem, item_src: InventoryItem) -> bool` - Joins the `item_src` item stack with the `item_dst` stack.
* `transfer_automerge(item: InventoryItem, destination: InventoryGridStacked) -> bool` - Transfers the given item stack into the given inventory, joining it with any available item stacks with the same prototype ID.
* `transfer_autosplitmerge(item: InventoryItem, destination: InventoryGridStacked) -> bool` - Transfers the given item stack into the given inventory, splitting it up and joining it with available item stacks, as needed.
