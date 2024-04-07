# `CtrlInventory`

Inherits: [Control](https://docs.godotengine.org/en/stable/classes/class_control.html)

Inherited by: [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md)

## Description

A UI control representing a basic `Inventory`. Displays a list of items in the inventory.

## Properties

* `inventory_path: NodePath` - Path to an `Inventory` node.
* `default_item_icon: Texture` - The default icon that will be used for items with no `image` property.
* `inventory: Inventory` - The `Inventory` node linked to this control.
* `select_mode: int` - Single or multi select mode (hold CTRL to select multiple items).

## Methods

* `get_selected_inventory_item() -> InventoryItem` - Returns the currently selected item. In case multiple items are selected, the first one is returned.
* `get_selected_inventory_items() -> Array[InventoryItem]` - Returns all the currently selected items.
* `select_inventory_item(item: InventoryItem) -> void` - Selects the given item.
* `deselect_inventory_item() -> void` - Deselects the selected item.

## Signals

* `inventory_item_activated(InventoryItem)` - Emitted when an `InventoryItem` is activated (i.e. double clicked).
* `inventory_item_context_activated(InventoryItem)` - Emitted when the context menu of an `InventoryItem` is activated (i.e. right clicked).
