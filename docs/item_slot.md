# `ItemSlot`

Inherits: `Node`

## Description

An item slot that can hold an inventory item.

An item slot that can hold an inventory item.

## Properties

* `prototree_json: JSON` - A JSON resource containing prototree information.

## Methods

* `can_hold_item(item: InventoryItem) -> bool` - Checks if the slot can hold the given item, i.e. the slot uses the same prototree as the item and the item is not `null`.
* `clear() -> bool` - Clears the item slot. Returns false if there's no item in the slot.
* `deserialize(source: Dictionary) -> bool` - Loads the item slot data from the given `Dictionary`.
* `equip(item: InventoryItem) -> bool` - Equips the given inventory item in the slot. If the slot already contains an item, clear() will be called first. Returns false if the clear call fails, the slot can't hold the given item, or already holds the given item. Returns true otherwise.
* `get_item() -> InventoryItem` - Returns the equipped item or `null` if there's no item in the slot.
* `serialize() -> Dictionary` - Serializes the item slot into a `Dictionary`.

## Signals

* `cleared()` - Emitted when the slot is cleared.Emitted when the slot is cleared.
* `item_equipped()` - Emitted when an item is placed in the slot.
* `prototree_json_changed()` - Emitted when the prototree_json property has been changed.

