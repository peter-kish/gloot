# `InventoryGrid`

Inherits: [`Inventory`](./inventory.md)

## Description

Inventory that has a limited capacity in terms of space. The inventory capacity is defined by its width and height.

## Properties

* `width: int`
* `height: int`
* `item_positions: Dictionary`

## Methods

* `get_item_position(item: InventoryItem) -> Vector2`
* `get_item_size(item: InventoryItem) -> Vector2`
* `add_item_at(item: InventoryItem, x: int, y: int) -> bool`
* `move_item(item: InventoryItem, x: int, y: int) -> bool`
* `transfer_to(item: InventoryItem, destination: InventoryGrid, x: int, y: int) -> bool`
* `rect_free(x: int, y: int, w: int, h: int, exception: InventoryItem = null) -> bool`
* `find_free_place(item: InventoryItem) -> Dictionary`
* `sort() -> bool`

## Signals

* `size_changed()`