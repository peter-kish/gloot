# `Inventory`

Inherits: `Node`

## Description

Basic stack-based inventory class.

Supports basic inventory operations (adding, removing, transferring items etc.). Can contain an unlimited amount of item stacks.

## Properties

* `protoset: JSON` - A JSON resource containing prototype information.

## Methods

* `get_prototree() -> ProtoTree` - Returns the inventory prototree parsed from the protoset JSON resource.
* `move_item(from: int, to: int) -> void` - Moves the item at the given index in the inventory to a new index.
* `get_item_index(item: InventoryItem) -> int` - Returns the index of the given item in the inventory.
* `get_item_count() -> int` - Returns the number of items in the inventory.
* `get_items() -> InventoryItem[]` - Returns an array containing all the items in the inventory.
* `has_item(item: InventoryItem) -> bool` - Checks if the inventory contains the given item.
* `add_item(item: InventoryItem) -> bool` - Adds the given item to the inventory.
* `can_add_item(item: InventoryItem) -> bool` - Checks if the given item can be added to the inventory.
* `create_and_add_item(prototype_id: String) -> InventoryItem` - Creates an `InventoryItem` based on the given prototype ID adds it to the inventory. Returns `null` if the item cannot be added.
* `remove_item(item: InventoryItem) -> bool` - Removes the given item from the inventory. Returns `false` if the item is not inside the inventory.
* `get_item_with_prototype_id(prototype_id: String) -> InventoryItem` - Returns the first found item with the given prototype ID.
* `get_items_with_prototype_id(prototype_id: String) -> InventoryItem[]` - Returns an array of all the items with the given prototype ID.
* `has_item_with_prototype_id(prototype_id: String) -> bool` - Checks if the inventory has an item with the given prototype ID.
* `get_constraint(script: Script) -> InventoryConstraint` - Returns the inventory constraint of the given type (script). Returns `null` if the inventory has no constraints of that type.
* `reset() -> void` - Removes all items from the inventory and sets its protoset to `null`.
* `clear() -> void` - Removes all the items from the inventory.
* `serialize() -> Dictionary` - Serializes the inventory into a `Dictionary`.
* `deserialize(source: Dictionary) -> bool` - Loads the inventory data from the given `Dictionary`.
* `split_stack(item: InventoryItem, new_stack_size: int) -> InventoryItem` - Splits the given item stack into two within the inventory. `new_stack_size` defines the size of the new stack, which is added to the inventory. Returns `null` if the split cannot be performed or if the new stack cannot be added to the inventory.
* `merge_stacks(item_dst: InventoryItem, item_src: InventoryItem, split_source: bool) -> bool` - Merges the `item_src` item stack into the `item_dst` stack which is inside the inventory. If `item_dst` doesn't have enough stack space and `split_source` is set to `true`, `item_src` will be split and only partially merged. Returns `false` if the merge cannot be performed.
* `add_item_automerge(item: InventoryItem) -> bool` - Adds the given item to the inventory and merges it with all compatible items. Returns `false` if the item cannot be added.
* `add_item_autosplit(item: InventoryItem) -> bool` - Adds the given item to the inventory, splitting it if there is not enough space for the whole stack.
* `add_item_autosplitmerge(item: InventoryItem) -> bool` - A combination of `add_item_autosplit` and `add_item_automerge`. Adds the given item stack into the inventory, splitting it up and joining it with available item stacks, as needed.
* `pack_item(item: InventoryItem) -> void` - Merges the given item with all compatible items in the same inventory.

## Signals

* `item_added(item)` - Emitted when an item has been added to the inventory.
* `item_removed(item)` - Emitted when an item has been removed from the inventory.
* `item_property_changed(item, property)` - Emitted when a property of an item inside the inventory has been changed.
* `item_moved(item)` - Emitted when an item has moved to a new index.
* `protoset_changed()` - Emitted when the protoset property has changed.
* `constraint_added(constraint)` - Emitted when a new constraint has been added to the inventory.
* `constraint_removed(constraint)` - Emitted when a constraint has been removed from the inventory.
* `constraint_changed(constraint)` - Emitted when an inventory constraint has changed.

