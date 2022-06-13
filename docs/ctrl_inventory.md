# `CtrlInventory`

Inherits: [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html)

Inherited by: [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md)

## Description

A UI control representing a basic `Inventory`. Displays a list of items in the inventory.

## Properties

* `inventory_path: NodePath` - Path to an `Inventory` node.
* `default_item_icon: Texture` - The default icon that will be used for items with no `image` property.
* `inventory: Inventory` - The `Inventory` node linked to this control.
* `item_list: ItemList` - TODO: Remove

## Methods

* `get_selected_inventory_items() -> Array` - Returns an array of selected items.
* `get_inventory_item(index: int) -> InventoryItem` - TODO: Remove
