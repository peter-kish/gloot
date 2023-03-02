# `Inventory`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

Inherited by: [`InventoryStacked`](./inventory_stacked.md), [`InventoryGrid`](./inventory_grid.md)

## Description

Basic inventory class. Supports basic inventory operations (adding, removing, transferring items etc.). Can contain an unlimited amount of items.

## Properties

* `item_protoset: Resource` - An `ItemProtoset` resource containing item prototypes.

## Methods

* `get_items() -> Array` - Returns an array containing all the items in the inventory.
* `move_item(from: int, to: int) -> void` - Moves the inventory item at index `from` to the new index `to`. This does not change the order of the inventory child nodes. It only affects the internal item ordering.
* `get_item_index(item: InventoryItem) -> int:` - Returns the internal item index of the given item. Returns `-1` if the item is not inside the inventory.
* `get_item_count() -> int` - Returns the number of items in the inventory.
* `has_item(item: InventoryItem) -> bool` - Checks if the inventory contains the given item.
* `add_item(item: InventoryItem) -> bool` - Adds the given item to the inventory.
* `create_and_add_item(prototype_id: String) -> InventoryItem` - Creates an `InventoryItem` based on the given prototype ID and adds it to the inventory. Returns `null` if the item cannot be added.
* `remove_item(item: InventoryItem) -> bool` - Removes the given item from the inventory.
* `remove_all_items() -> bool` - Removes the all items from the inventory.
* `get_item_by_id(prototype_id: String) -> InventoryItem` - Returns the first found item with the given prototype ID.
* `get_items_by_id(prototype_id: String) -> Array` - Returns an array of items with the given prototype ID.
* `has_item_by_id(prototype_id: String) -> bool` - Checks if the inventory contains an item with the given prototype ID.
* `transfer(item: InventoryItem, destination: Inventory) -> bool` - Transfers the given item into the given inventory.
* `clear() -> void` - Clears all items from the inventory.
* `reset() -> void` - Resets the inventory to its default state. This includes clearing its contents and resetting all properties.
* `serialize() -> Dictionary` - Serializes the inventory into a dictionary.
* `deserialize(source: Dictionary) -> bool` - Loads the inventory data from the given dictionary.

## Signals

* `item_added(item: InventoryItem)` - Emitted when an item has been added to the inventory.
* `item_removed(item: InventoryItem)` - Emitted when an item has been removed from the inventory.
* `item_modified(item: InventoryItem)` - Emitted when an item from the inventory has been modified.
* `contents_changed()` - Emitted when the contents of the inventory have changed.
* `protoset_changed()` - Emitted when the `item_protoset` property has been changed.