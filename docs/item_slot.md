# `ItemSlot`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Holds a reference to a given item from a given inventory. The slot can be cleared or bound to one item at a time. In case the item is removed from the inventory or the slot is bound to a different inventory, the slot is automatically cleared.

## Properties

* `inventory: Inventory` - An `Inventory` this item slot is linked to.
* `item: InventoryItem` - The `InventoryItem` held by this slot.

## Methods

* `can_hold_item(new_item: InventoryItem) -> bool` - Checks if the slot can hold the given item (i.e. if the item is inside `inventory`).

## Signals

* `item_set(InventoryItem item)` - Emitted when an item is placed in the slot.
* `item_cleared()` - Emitted when the slot is cleared.
* `inventory_changed(Inventory inventory)` - Emitted when the linked inventory is changed.