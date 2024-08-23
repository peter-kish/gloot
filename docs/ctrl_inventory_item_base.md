# `CtrlInventoryItemBase`

Inherits: `Control`

## Description

Base class for `CtrlInventoryItem`.

`CtrlInventoryItemBase` defines some signals and members used for displaying an `InventoryItem`. Must be inherited when defining a custom class for representing inventory items.

## Properties

* `item: InventoryItem` - Reference to the `InventoryItem` that is being displayed.
* `icon_stretch_mode: int` - Controls the item icon behavior when resizing the node's bounding rectangle. See the `TextureRect.StretchMode` constants for details.

## Signals

* `item_changed()` - Emitted when the `item` property has been changed.
* `pre_item_changed()` - Emitted when the `item` property is about to be changed. Useful for disconnecting item signals before referencing a new item.
* `icon_stretch_mode_changed()` - Emitted when the `icon_stretch_mode` property has been changed.

