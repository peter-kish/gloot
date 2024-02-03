# `InventoryGrid`

Inherits: [`Inventory`](./inventory.md)

## Description

Inventory that has a limited capacity in terms of space. The inventory capacity is defined by its width and height.

## Properties

* `size: Vector2i` - The size of the inventory (width and height).

## Methods

* `get_item_position(item: InventoryItem) -> Vector2i` - Returns the position of the given item in the inventory.
* `get_item_size(item: InventoryItem) -> Vector2i` - Returns the size of the given item.
* `get_item_rect(item: InventoryItem) -> Rect2i` - Returns the position and size of the given item in the inventory.
* `is_item_rotated(item: InventoryItem) -> bool` - Checks if the item is rotated (indicated by the `rotated` property).
* `is_item_rotation_positive(item: InventoryItem) -> bool` - Checks if the item rotation is positive (indicated by the `positive_rotation` property).
* `add_item_at(item: InventoryItem, position: Vector2i) -> bool` - Adds the given to the inventory, at the given position.
* `create_and_add_item_at(prototype_id: String, position: Vector2i) -> InventoryItem` - Creates an `InventoryItem` based on the given prototype ID and adds it to the inventory at the given position. Returns `null` if the item cannot be added.
* `get_item_at(position: Vector2i) -> InventoryItem` - Returns the item at the given position in the inventory. Returns `null` if the given field is empty.
* `move_item_to(item: InventoryItem, position: Vector2i) -> bool` - Moves the given item in the inventory to the new given position.
* `transfer_to(item: InventoryItem, destination: InventoryGrid, position: Vector2i) -> bool` - Transfers the given item to the given inventory to the given position.
* `rect_free(rect: Rect2, exception: InventoryItem = null) -> bool` - Checks if the given rectangle is not occupied by any items (with a given optional exception).
* `find_free_place(item: InventoryItem) -> Dictionary` - Finds a free place for the given item. Returns a dictionary with two fields: `success` and `position`. If `success` is `true` a free place has been found and is stored in the `position` field. Otherwise `success` is set to false.
* `sort() -> bool` - Sorts the inventory items by size.

## Signals

* `size_changed()` - Emitted when the size of the inventory has changed.