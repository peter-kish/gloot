# `Inventory`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

Inherited by: [`InventoryStacked`](./inventory_stacked.md), [`InventoryGrid`](./inventory_grid.md)

## Description

Basic inventory class. Supports basic inventory operations (adding, removing, transferring items etc.). Can contain an unlimited amount of items.

## Properties

* `item_protoset: Resource`
* `contents: Array`

## Methods

* `get_items() -> Array`
* `has_item(item: InventoryItem) -> bool`
* `add_item(item: InventoryItem) -> bool`
* `remove_item(item: InventoryItem) -> bool`
* `get_item_by_id(id: String) -> InventoryItem`
* `has_item_by_id(id: String) -> bool`
* `transfer(item: InventoryItem, destination: Inventory) -> bool`

## Signals

* `item_added(item: InventoryItem)`
* `item_removed(item: InventoryItem)`
* `contents_changed()`