# `ItemSlot`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Holds a reference to a given item from a given inventory. The slot can be cleared or bound to one item at a time. In case the item is removed from the inventory or the slot is bound to a different inventory, the slot is automatically cleared.

## Properties

* `inventory: Inventory`
* `item: InventoryItem`

## Methods

* `can_hold_item(new_item: InventoryItem) -> bool`

## Signals

* `item_set(InventoryItem item)`
* `item_cleared()`
* `inventory_changed(Inventory inventory)`