# `CtrlItemSlot`

Inherits: [Control](https://docs.godotengine.org/en/stable/classes/class_control.html)

## Description

A UI control representing an inventory slot (`ItemSlot`). Displays the texture of the set item and its name. If not item is set, it displays the given default texture.

## Properties

* `item_slot_path: NodePath` - Path to an `ItemSlot` node.
* `default_item_icon: Texture` - The default icon that will be used for items with no `image` property.
* `icon_scaling: Vector2` - Item icon scaling.
* `item_texture_visible: bool` - The item texture is displayed if set to true.
* `label_visible: bool` - The item name label is displayed if set to true.
* `item_slot: ItemSlot` - The `ItemSlot` node linked to this control.

## Signals

* `item_mouse_entered(InventoryItem)` - Emitted when the mouse enters the `Rect` area of the control representing the given `InventoryItem`.
* `item_mouse_exited(InventoryItem)` - Emitted when the mouse leaves the `Rect` area of the control representing the given `InventoryItem`.
