# `CtrlInventoryItemBase`

Inherits: `Control`

## Description

Base class for `CtrlInventoryItem`.

`CtrlInventoryItemBase` defines some signals and members used for displaying an `InventoryItem`. Must be inherited when defining a custom class for representing inventory items.

## Properties

* `item: InventoryItem` - Reference to the `InventoryItem` that is being displayed.
* `icon_stretch_mode: int` - Controls the item icon behavior when resizing the node's bounding rectangle. See the `TextureRect.StretchMode` constants for details.
* `icon_flip_h: bool` - If `true`, the icon is flipped horizontally
* `icon_flip_v: bool` - If `true`, the icon is flipped vertically

## Signals

* `item_changed()` - Emitted when the `item` property has been changed.
* `icon_stretch_mode_changed()` - Emitted when the `icon_stretch_mode` property has been changed.
* `icon_flip_h_changed()` - Emitted when the `icon_flip_h` property has been changed.
* `icon_flip_v_changed()` - Emitted when the `icon_flip_v` property has been changed.

