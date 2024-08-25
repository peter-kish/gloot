# `InventoryItem`

Inherits: `RefCounted`

## Description

Stack-based inventory item class.

It is based on an item prototype from an prototree. Can hold additional properties. The default stack size and maximum stack size is 1, which can be changed by setting the `stack_size` and `maximum_stack_size` properties inside the prototype or directly inside the item.

## Properties

* `protoset: JSON` - A JSON resource containing prototype information.

## Methods

* `get_prototree() -> ProtoTree` - Returns the inventory prototree parsed from the protoset JSON resource.
* `get_prototype() -> Prototype` - Returns the item prototype.
* `duplicate() -> InventoryItem` - Returns a duplicate of the item.
* `get_inventory() -> Inventory` - Returns the `Inventory` this item belongs to, or `null` if it is not inside an inventory.
* `swap(item1: InventoryItem, item2: InventoryItem) -> bool` - Swaps the two given items. Returns `false` if the items cannot be swapped.
* `has_property(property_name: String) -> bool` - Checks if the item has the given property.
* `get_property(property_name: String, default_value: Variant) -> Variant` - Returns the given item property. If the item does not define the item property, `default_value` is returned.
* `set_property(property_name: String, value: Variant) -> void` - Sets the given item property to the given value.
* `clear_property(property_name: String) -> void` - Clears (un-defines) the given item property.
* `get_overridden_properties() -> Array` - Returns an array of properties that the item overrides.
* `get_properties() -> Array` - Returns an array of item properties (includes prototype properties).
* `is_property_overridden(property_name: Variant) -> bool` - Checks if the item overrides the given property.
* `reset() -> void` - Resets item data. Clears its properties and sets its protoset to `null`.
* `serialize() -> Dictionary` - Serializes the item into a `Dictionary`.
* `deserialize(source: Dictionary) -> bool` - Loads the item data from the given `Dictionary`.
* `get_texture() -> Texture2D` - Helper function for retrieving the item texture. It checks the image item property and loads it as a texture, if available.
* `get_title() -> String` - Helper function for retrieving the item title. It checks the name item property and uses it as the title, if available. Otherwise, prototype_id is returned as title.
* `get_stack_size() -> int` - Returns the stack size.
* `get_max_stack_size() -> int` - Returns the maximum stack size.
* `set_stack_size(stack_size: int) -> bool` - Sets the stack size.
* `set_max_stack_size(max_stack_size: int) -> void` - Sets the maximum stack size.
* `merge_into(item_dst: InventoryItem, split: bool) -> bool` - Merges the item stack into the `item_dst` stack. If `item_dst` doesn't have enough stack space and `split` is set to `true`, the stack will be split and only partially merged. Returns `false` if the merge cannot be performed.
* `can_merge_into(item_dst: InventoryItem, split: bool) -> bool` - Checks if the item stack can be merged into `item_dst` with, or without splitting (`split` parameter).
* `compatible_with(item_dst: InventoryItem) -> bool` - Checks if the item stack is compatible for merging with `item_dst`.
* `get_free_stack_space() -> int` - Returns the free stack space in the item stack (maximum_stack_size - stack_size).
* `split(new_stack_size: int) -> InventoryItem` - Splits the item stack into two and returns a reference to the new stack. `new_stack_size` defines the size of the new stack. Returns `null` if the split cannot be performed.
* `can_split(new_stack_size: int) -> bool` - Checks if the item stack can be split using the given new stack size.

## Signals

* `property_changed(property_name)` - Emitted when an item property has changed.

