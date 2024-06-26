# `CtrlInventory`

Inherits: `ItemList`

## Description

Control node for displaying inventories.

Displays inventories as an `ItemList`.

## Properties

* `inventory: Inventory` - Reference to the inventory that is being displayed.

## Methods

* `deselect_inventory_items() -> void` - Deselects all selected inventory items.
* `get_selected_inventory_item() -> InventoryItem` - Returns the selected inventory item. If multiple items are selected, it returns the first one.
* `get_selected_inventory_items() -> InventoryItem[]` - Returns an array of selected inventory items.
* `select_inventory_item(item: InventoryItem) -> void` - Selects the given inventory item.

## Signals

* `inventory_item_activated(item)` - Emitted when an inventory item double-clicked.
* `inventory_item_context_activated(item)` - Emitted when an inventory item right-clicked.

