# `CtrlInventoryGrid`

Inherits: [CtrlInventory](./ctrl_inventory.md)

## Description

A UI control representing a grid based inventory (`InventoryGrid`). Displays a grid based on the inventory capacity (width and height) and the contained items on the grid. The items can be moved around in the inventory by dragging.

## Properties

* `field_dimensions: Vector2`
* `grid_color: Color`
* `inventory_path: NodePath`
* `default_item_texture: Texture`
* `inventory: InventoryGrid`
* `grab_offset: Vector2`

## Signals

* `item_dropped(InventoryItem, Vector2)`