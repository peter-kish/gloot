# `ItemCountConstraint`

Inherits: `InventoryConstraint`

## Description

A constraint that limits the inventory to a given item count.

The constraint implements a count-based inventory where the total number of items cannot exceed the configured capacity of the inventory.

## Properties

* `capacity: int` - Maximum number of items the inventory can hold.

## Methods

* `deserialize(source: Dictionary) -> bool` - Loads the constraint data from the given `Dictionary`.
* `get_free_space() -> int` - Returns the number of items that can be added to the inventory.
* `get_occupied_space() -> int` - Returns the total number of items in the inventory.
* `get_space_for(item: InventoryItem) -> int` - Returns the number of times this constraint can receive the given item.
* `has_space_for(item: InventoryItem) -> bool` - Checks if the constraint can receive the given item.
* `reset() -> void` - Resets the constraint, i.e. sets its capacity to default (`1`).
* `serialize() -> Dictionary` - Serializes the constraint into a `Dictionary`.

