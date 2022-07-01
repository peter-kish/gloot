# `CtrlItemSlot`

Inherits: [HBoxContainer](https://docs.godotengine.org/en/stable/classes/class_hboxcontainer.html)

## Description

A UI control representing an inventory slot (`ItemSlot`). Displays the texture of the set item and its name. If not item is set, it displays the given default texture.

## Properties

* `item_slot_path: NodePath` - Path to an `ItemSlot` node.
* `default_item_icon: Texture` - The default item texture that will be used in case there is not item set.
* `item_texture_visible: bool` - The item texture is displayed if set to true.
* `label_visible: bool` - The item name label is displayed if set to true.
* `item_slot: ItemSlot` - The `ItemSlot` node linked to this control.
