# `WeightConstraint`

Inherits: `InventoryConstraint`

## Description

A constraint that limits the inventory to a given weight capacity.

The constraint implements a weight-based inventory where the total sum of the item weights cannot exceed the configured capacity of the inventory.

## Properties

* `capacity: float` - Maximum weight the inventory can hold.

## Methods

* `get_occupied_space() -> float` - Returns the total sum of the item weights.
* `get_free_space() -> float` - Returns the available space in the inventory.
* `get_item_weight(item: InventoryItem) -> float` - Returns the weight of the given item (i.e. the `weight` property).
* `set_item_weight(item: InventoryItem, weight: float) -> void` - Sets the weight of the given item (i.e. the `weight` property).
* `get_space_for(item: InventoryItem) -> int` - Returns the number of times this constraint can receive the given item.
* `has_space_for(item: InventoryItem) -> bool` - Checks if the constraint can receive the given item.
* `reset() -> void` - Resets the constraint, i.e. sets its capacity to default (`1.0`).
* `serialize() -> Dictionary` - Serializes the constraint into a `Dictionary`.
* `deserialize(source: Dictionary) -> bool` - Loads the constraint data from the given `Dictionary`.

