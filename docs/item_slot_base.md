# `ItemSlotBase`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Base class for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md)

## Methods

* `equip(item: InventoryItem) -> bool` - Equips the given inventory item in the slot. See the documentation for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md) for more details.
* `clear() -> bool` - Clears the item slot. See the documentation for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md) for more details.
* `get_item() -> InventoryItem` - Returns the equipped item. See the documentation for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md) for more details.
* `can_hold_item(new_item: InventoryItem) -> bool` - Checks if the slot can hold the given item. See the documentation for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md) for more details.
* `reset()` - Clears the item slot. See the documentation for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md) for more details.
* `serialize() -> Dictionary` - Serializes the item slot into a dictionary. See the documentation for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md) for more details.
* `deserialize(source: Dictionary) -> bool` - Loads the item slot data from the given dictionary. See the documentation for [`ItemSlot`](./item_slot.md) and [`ItemRefSlot`](./item_ref_slot.md) for more details.

## Signals

* `item_equipped()` - Emitted when an item is placed in the slot.
* `cleared()` - Emitted when the slot is cleared.