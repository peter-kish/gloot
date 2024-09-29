# `InventoryStacked`

Inherits: [`Inventory`](./inventory.md)

## Description

Inventory that has a limited item capacity in terms of weight.

## Properties

* `capacity: float` - Maximum weight the inventory can hold. Set to 0.0 for unlimited capacity.
* `occupied_space: float` - Currently occupied space in the inventory.

## Methods

* `static get_item_stack_size(item: InventoryItem) -> int` - Returns the stack size of the given item.
* `static set_item_stack_size(item: InventoryItem, new_stack_size: int) -> bool` - Sets the stack size of the given item. If the stack size is set to 0 the item will be removed from its directory and queued for deletion. If `new_stack_size` is greater than the maximum stack size or negative, the stack size will remain unchanged and the function will return `false`.
* `static get_item_max_stack_size(item: InventoryItem) -> int` - Returns the maximum stack size for the given item.
* `static set_item_max_stack_size(item: InventoryItem, new_stack_size: int) -> void` - Sets the maximum stack size for the given item.
* `get_prototype_stack_size(prototype_id: String) -> int` - Returns the stack size of the given item prototype.
* `get_prototype_max_stack_size(prototype_id: String) -> int` - Returns the maximum stack size of the given item prototype.
* `add_item_automerge(item: InventoryItem) -> bool` - Adds the given item stack to the inventory, automatically merging with existing item stacks with the same prototype ID.
* `has_unlimited_capacity() -> bool` - Checks if the inventory has unlimited capacity (i.e. capacity is 0.0).
* `get_free_space() -> float` - Returns the free available space in the inventory.
* `has_place_for(item: InventoryItem) -> bool` - Checks if the inventory has enough free space for the given item.
* `split(item: InventoryItem, new_stack_size: int) -> InventoryItem` - Splits the given item stack into two. The newly created stack will have the size `new_stack_size`, while the old stack will contain the remainder.
* `join(item_dst: InventoryItem, item_src: InventoryItem) -> bool` - Joins the `item_src` item stack with the `item_dst` stack.
* `join_autosplit(item_dst: InventoryItem, item_src: InventoryItem) -> bool` - Joins the `item_src` item stack with the `item_dst` stack, splitting it up `item_src` as needed.
* `transfer_autosplit(item: InventoryItem, destination: InventoryStacked) -> bool` - Transfers the given item stack into the given inventory, splitting it if there is not enough space for the whole stack.
* `transfer_automerge(item: InventoryItem, destination: InventoryStacked) -> bool` - Transfers the given item stack into the given inventory, joining it with any available item stacks with the same prototype ID.
* `transfer_autosplitmerge(item: InventoryItem, destination: InventoryStacked) -> bool` - A combination of `transfer_autosplit()` and `transfer_automerge`. Transfers the given item stack into the given inventory, splitting it up and joining it with available item stacks, as needed.
* `static pack(item: InventoryItem) -> void:` - Merges the given item with all compatible items in the same inventory.

## Signals

* `capacity_changed()` - Emitted when the inventory capacity has changed.
* `occupied_space_changed()` - Emitted when the amount of occupied space in the inventory has changed.