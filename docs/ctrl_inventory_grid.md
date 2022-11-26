# `CtrlInventoryGrid`

Inherits: [Control](https://docs.godotengine.org/en/stable/classes/class_control.html)

## Description

A UI control representing a grid based inventory (`InventoryGrid`). Displays a grid based on the inventory capacity (width and height) and the contained items on the grid. The items can be moved around in the inventory by dragging.

## Properties

* `field_dimensions: Vector2` - The size of each inventory field in pixels.
* `item_spacing: int` - The spacing between items in pixels.
* `draw_grid: bool` - Displays a grid if true.
* `grid_color: Color` - The color of the grid.
* `draw_selections: bool` - Draws a rectangle behind the selected item if true.
* `selection_color: Color` - The color of the selection.
* `inventory_path: NodePath` - Path to an `Inventory` node.
* `default_item_texture: Texture` - The default texture that will be used for items with no `image` property.
* `stretch_item_sprites: bool` - If true, the inventory item sprites will be stretched to fit the inventory fields they are positioned on.
* `drag_sprite_z_index: int` - The z-index used for the dragged `InventoryItem` in order to appear above other UI elements.
* `inventory: InventoryGrid` - The `Inventory` node linked to this control.

## Methods

* `get_field_coords(global_pos: Vector2) -> Vector2` - Converts the given global coordinates to local inventory field coordinates.
* `get_selected_inventory_items() -> Array` - Returns the currently selected items.

## Signals

* `item_dropped(InventoryItem, Vector2)` - Emitted when a grabbed `InventoryItem` is dropped.
* `inventory_item_activated(InventoryItem)` - Emitted when an `InventoryItem` is activated (i.e. double clicked).
* `item_selected(InventoryItem)` - Emitted when an `InventoryItem` is selected.
* `item_deselected(InventoryItem)` - Emitted when an `InventoryItem` is deselected.
* `item_mouse_entered(InventoryItem)` - Emitted when the mouse enters the `Rect` area of the control representing the given `InventoryItem`.
* `item_mouse_exited(InventoryItem)` - Emitted when the mouse leaves the `Rect` area of the control representing the given `InventoryItem`.