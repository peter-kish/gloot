# `InventoryStacked`

Inherits: [`Inventory`](./inventory.md)

## Description

Inventory that has a limited item capacity in terms of weight.

## Properties

* `capacity: float` - Maximum weight the inventory can hold. Set to 0.0 for unlimited capacity.
* `occupied_space: float` - Currently occupied space in the inventory.

## Methods

* `add_item_automerge(item: InventoryItem) -> bool` - Adds the given item stack to the inventory, automatically merging with existing item stacks with the same prototype ID.
* `has_unlimited_capacity() -> bool` - Checks if the inventory has unlimited capacity (i.e. capacity is 0.0).
* `get_free_space() -> float` - Returns the free available space in the inventory.
* `has_place_for(item: InventoryItem) -> bool` - Checks if the inventory has enough free space for the given item.
* `split(item: InventoryItem, new_stack_size: int) -> InventoryItem` - Splits the given item stack into two. The newly created stack will have the size `new_stack_size`, while the old stack will contain the remainder.
* `join(stack_1: InventoryItem, stack_2: InventoryItem) -> bool` - Joins two item stack into one.
* `transfer_autosplit(item: InventoryItem, destination: Inventory) -> bool` - Transfers the given item stack into the given inventory, splitting it if there is not enough space for the whole stack.
* `transfer_automerge(item: InventoryItem, destination: Inventory) -> bool` - Transfers the given item stack into the given inventory, joining it with any available item stacks with the same prototype ID.
* `transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool` - A combination of `transfer_autosplit()` and `transfer_automerge`. Transfers the given item stack into the given inventory, splitting it up and joining it with available item stacks, as needed.

## Signals

* `capacity_changed()` - Emitted when the inventory capacity has changed.
* `occupied_space_changed()` - Emitted when the amount of occupied space in the inventory has changed.