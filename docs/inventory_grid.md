# `InventoryGrid`

Inherits: [`Inventory`](./inventory.md)

## Description

Inventory that has a limited capacity in terms of space. The inventory capacity is defined by its width and height.

## Properties

* `width: int` - The width of the inventory.
* `height: int` - The height of the inventory.
* `item_positions: Dictionary` - A dictionary holding the positions (as `Vector2`) of all items in the inventory.

## Methods

* `get_item_position(item: InventoryItem) -> Vector2` - Returns the position of the given item in the inventory.
* `get_item_size(item: InventoryItem) -> Vector2` - Returns the size of the given item.
* `add_item_at(item: InventoryItem, x: int, y: int) -> bool` - Adds the given to the inventory, at the given position.
* `move_item(item: InventoryItem, x: int, y: int) -> bool` - Moves the given item in the inventory to the new given position.
* `transfer_to(item: InventoryItem, destination: InventoryGrid, x: int, y: int) -> bool` - Transfers the given item to the given inventory to the given position.
* `rect_free(x: int, y: int, w: int, h: int, exception: InventoryItem = null) -> bool` - Checks if the given rectangle is not occupied by any items (with a given optional exception).
* `find_free_place(item: InventoryItem) -> Dictionary` - Finds a free place for the given item.
* `sort() -> bool` - Sorts the inventory items by size.

## Signals

* `size_changed()` - Emitted when the size of the inventory has changed.