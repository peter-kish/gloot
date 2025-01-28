# `CtrlItemSlot`

Inherits: `Control`

## Description

A control node representing an inventory slot (`ItemSlot`).

Displays the currently equipped item with a configurable background.

## Properties

* `item_slot: ItemSlot` - Reference to the item slot that is being displayed.
* `icon_stretch_mode: int` - Controls the item icon behavior when resizing the node's bounding rectangle. See the `TextureRect.StretchMode` constants for details.
* `slot_style: StyleBox` - The slot background style.
* `slot_highlighted_style: StyleBox` - The slot background style when the mouse cursor hovers over the slot.

