# `CtrlInventoryGrid`

Inherits: `Control`

## Description

Control node for displaying inventories with a GridConstraint.

Displays the inventory contents on a 2D grid. The grid style, size and item icons are customizable.

## Properties

* `inventory: Inventory` - Reference to an inventory with a GridConstraint that is being displayed.
* `stretch_item_icons: bool` - If enabled, stretches the icons based on `field_dimensions`.
* `field_dimensions: Vector2` - Size of individual fields in the grid.
* `item_spacing: int` - Spacing between grid fields.
* `select_mode: int` - Item selection mode. Set to SelectMode.SELECT_MULTI to enable selecting multiple items by holding down CTRL. See the `ItemList.SelectMode` constants for details.
* `custom_item_control_scene: PackedScene` - Custom control scene representing an `InventoryItem` (must inherit `CtrlInventoryItemBase`). If set to `null`, `CtrlInventoryItem` will be used to represent the item.
* `drag_tint: Color` - Multiplies the color of the item's texture when dragging.
* `field_style: StyleBox` - The default grid field background style. Unlike `background_style`, this style is used when displaying each individual field in the 2D grid.
* `field_highlighted_style: StyleBox` - The grid field style used when hovering over it with the mouse.
* `field_selected_style: StyleBox` - The grid field style used for selected items. Unlike `selection_style`, this style is used as field background behind selected items.
* `selection_style: StyleBox` - The style used for displaying item selections. Unlike `field_selected_style`, this style is used when displaying rectangles over the selected items.
* `background_style: StyleBox` - The style used for the inventory background. Unlike `field_style`, this style is used when displaying a rectangle behind the 2D grid.

## Methods

* `deselect_inventory_items() -> void` - Deselects all selected inventory items.
* `select_inventory_item(item: InventoryItem) -> void` - Selects the given inventory item.
* `get_selected_inventory_item() -> InventoryItem` - Returns the selected inventory item. If multiple items are selected, it returns the first one.
* `get_selected_inventory_items() -> InventoryItem[]` - Returns an array of selected inventory items.

## Signals

* `item_dropped(item, offset)` - Emitted when an item has been dropped onto the 2D grid.
* `selection_changed()` - Emitted when the item selection has changed.
* `inventory_item_activated(item)` - Emitted when an inventory item has been double-clicked.
* `inventory_item_clicked(item)` - Emitted when an inventory item has been right-clicked.
* `inventory_item_selected(item)` - Emitted when an inventory item has been selected.
* `item_mouse_entered(item)` - Emitted when the mouse cursor has entered the visible area of an item.
* `item_mouse_exited(item)` - Emitted when the mouse cursor has exited the visible area of an item.

