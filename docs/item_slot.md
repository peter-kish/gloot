# `ItemSlot`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Holds an inventory item.

## Properties

* `item_protoset: ItemProtoset` - An `ItemProtoset` resource containing item prototypes that the slot can receive.

## Methods

* `equip(item: InventoryItem) -> bool` - Equips the given inventory item in the slot.
* `clear(return_item_to_source_inventory: bool = true) -> bool` - Clears the item slot. By default, the slot will remember the inventory from which the item came from and it will try to place the item back into that inventory when the slot is cleared. To avoid this, set the `restore_item_to_source_inventory` parameter to `false`. Note that the item slot does not free the item after the slot is cleared, regardless if it has been returned to the source inventory, or not.
* `can_hold_item(new_item: InventoryItem) -> bool` - Checks if the slot can hold the given item.
* `reset()` - Resets the item slot (i.e. clears it).
* `serialize() -> Dictionary` - Serializes the item slot into a dictionary.
* `deserialize(source: Dictionary) -> bool` - Loads the item slot data from the given dictionary.

## Signals

* `item_equipped()` - Emitted when an item is placed in the slot.
* `item_cleared()` - Emitted when the slot is cleared.
* `protoset_changed()` - Emitted when the `item_protoset` property has been changed.