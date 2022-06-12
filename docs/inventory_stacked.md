# `InventoryStacked`

Inherits: [`Inventory`](./inventory.md)

## Description

Inventory that has a limited item capacity in terms of weight.

## Properties

* `capacity: float`
* `occupied_space: float`

## Methods

* `has_unlimited_capacity() -> bool`
* `get_free_space() -> float`
* `has_place_for(item: InventoryItem) -> bool`
* `split(item: InventoryItem, new_stack_size: int) -> InventoryItem`
* `join(stack_1: InventoryItem, stack_2: InventoryItem) -> bool`
* `transfer_autosplit(item: InventoryItem, destination: Inventory) -> bool`
* `transfer_automerge(item: InventoryItem, destination: Inventory) -> bool`
* `transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool`

## Signals

* `capacity_changed()` 
* `occupied_space_changed()` 