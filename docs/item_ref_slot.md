# `ItemRefSlot`

Inherits: [ItemSlotBase](./item_slot_base.md)

## Description

Holds a reference to an inventory item.

## Properties

* `inventory_path: NodePath` - Path to an `Inventory` node. Sets the `inventory` property.
* `inventory: Inventory` - Reference to an `Inventory` node.

## Methods

* `equip(item: InventoryItem) -> bool` - Equips the given inventory item in the slot. If the slot already holds an item, `clear()` will be called first. Returns `false` if the `clear` call fails, the slot can't hold the given item, or already holds the given item. Returns `true` otherwise.
* `clear() -> bool` - Clears the item slot.
* `get_item() -> InventoryItem` - Returns the equipped item.
* `can_hold_item(new_item: InventoryItem) -> bool` - Checks if the slot can hold the given item, i.e. `inventory` contains the given item and the item is not `null`. This method can be overridden to implement item slots that can only hold specific items.
* `reset()` - Clears the item slot.
* `serialize() -> Dictionary` - Serializes the item slot into a dictionary.
* `deserialize(source: Dictionary) -> bool` - Loads the item slot data from the given dictionary. 
    > Note: `inventory` must be set prior to the `deserialize` call!

## Signals

* `item_equipped()` - Emitted when an item is placed in the slot.
* `item_cleared()` - Emitted when the slot is cleared.