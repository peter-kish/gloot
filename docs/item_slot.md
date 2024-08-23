# `ItemSlot`

Inherits: `Node`

## Description

An item slot that can hold an inventory item.

An item slot that can hold an inventory item.

## Properties

* `protoset: JSON` - A JSON resource containing prototype information.

## Methods

* `equip(item: InventoryItem) -> bool` - Equips the given inventory item in the slot. If the slot already contains an item, clear() will be called first. Returns false if the clear call fails, the slot can't hold the given item, or already holds the given item. Returns true otherwise.
* `clear() -> bool` - Clears the item slot. Returns false if there's no item in the slot.
* `get_item() -> InventoryItem` - Returns the equipped item or `null` if there's no item in the slot.
* `can_hold_item(item: InventoryItem) -> bool` - Checks if the slot can hold the given item, i.e. the slot uses the same protoset as the item and the item is not `null`.
* `serialize() -> Dictionary` - Serializes the item slot into a `Dictionary`.
* `deserialize(source: Dictionary) -> bool` - Loads the item slot data from the given `Dictionary`.

## Signals

* `protoset_changed()` - Emitted when the protoset property has been changed.
* `item_equipped()` - Emitted when an item is placed in the slot.
* `cleared()` - Emitted when the slot is cleared.Emitted when the slot is cleared.

