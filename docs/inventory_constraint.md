# `InventoryConstraint`

Inherits: `Node`

## Description

Base inventory constraint class.

Base inventory constraint class which implements some basic constraint functionality and defines methods that can be overridden.

## Properties

* `inventory: Inventory` - Reference to an inventory that this constraint belongs to.

## Methods

* `get_space_for(item: InventoryItem) -> int` - Returns the number of times this constraint can receive the given item.
* `has_space_for(item: InventoryItem) -> bool` - Checks if the constraint can receive the given item.
* `serialize() -> Dictionary` - Serializes the constraint into a `Dictionary`.
* `deserialize(source: Dictionary) -> bool` - Loads the constraint data from the given `Dictionary`.

## Signals

* `changed()` - Emitted when the state of the constraint has changed.

