# `CtrlInventoryGrid`

Inherits: [CtrlInventory](./ctrl_inventory.md)

## Description

A UI control representing a grid based inventory (`InventoryGrid`). Displays a grid based on the inventory capacity (width and height) and the contained items on the grid. The items can be moved around in the inventory by dragging.

## Properties

* `field_dimensions: Vector2` - The size of each inventory field.
* `grid_color: Color` - The color of the grid.
* `inventory_path: NodePath` - Path to an `Inventory` node.
* `default_item_texture: Texture` - The default texture that will be used for items with no `image` property.
* `inventory: InventoryGrid` - The `Inventory` node linked to this control.
* `grabbed_ctrl_inventory_item` - The `CtrlInventoryItemRect` currently grabbed by the user.
* `grab_offset: Vector2` - An offset by which the currently grabbed `CtrlInventoryItemRect` is held.

## Signals

* `item_dropped(InventoryItem, Vector2)` - Emitted when a grabbed `CtrlInventoryItemRect` is dropped.