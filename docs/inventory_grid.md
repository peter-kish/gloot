# `InventoryGrid`

Inherits: [`Inventory`](./inventory.md)

## Description

Inventory that has a limited capacity in terms of space. The inventory capacity is defined by its width and height.

## Properties

* `size: Vector2` - The size of the inventory (width and height).

> **NOTE**: Because Godot 3.x currently lacks a `Vector2i` type (available only in unstable versions), `InventoryGrid` uses `Vector2` where the `x` a nd `y` coordinates are rounded to `int`s.

## Methods

* `get_item_position(item: InventoryItem) -> Vector2` - Returns the position of the given item in the inventory.
* `get_item_size(item: InventoryItem) -> Vector2` - Returns the size of the given item.
* `get_item_rect(item: InventoryItem) -> Rect2` - Returns the position and size of the given item in the inventory.
* `add_item_at(item: InventoryItem, position: Vector2) -> bool` - Adds the given to the inventory, at the given position.
* `move_item(item: InventoryItem, position: Vector2) -> bool` - Moves the given item in the inventory to the new given position.
* `transfer_to(item: InventoryItem, destination: InventoryGrid, position: Vector2) -> bool` - Transfers the given item to the given inventory to the given position.
* `rect_free(rect: Rect2, exception: InventoryItem = null) -> bool` - Checks if the given rectangle is not occupied by any items (with a given optional exception).
* `find_free_place(item: InventoryItem) -> Vector2` - Finds a free place for the given item. Returns Vector(-1, -1) if no place is found.
* `sort() -> bool` - Sorts the inventory items by size.

## Signals

* `size_changed()` - Emitted when the size of the inventory has changed.