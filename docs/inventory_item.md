# `InventoryItem`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Inventory item class. It is based on an item prototype from an [`ItemProtoset`](./item_protoset.md) resource. Can hold additional properties.

> NOTE: This class and its derivatives are defined with the `@tool` attribute so that inventories can be edited from within the Godot editor. Make sure to add the `@tool` attribute when inheriting from this class to make it usable in the editor, since GDScript will not consider it a `@tool` even though it is defined as such in its base.

## Properties

* `protoset: Resource` - An `ItemProtoset` resource containing item prototypes.
* `prototype_id: String` - ID of the prototype from `protoset` this item is based on.

## Methods

* `get_inventory() -> Inventory` - Returns the `Inventory` this item belongs to.
* `get_item_slot() -> ItemSlot` - Returns the `ItemSlot` this item is equipped in.
* `get_defined_properties() -> Dictionary` - Returns a dictionary with all the properties the item defines or overrides.
* `get_properties() -> Dictionary` - Returns a dictionary containing all item properties.
* `defines_property(property_name: String) -> bool` - Returns `true` if the item defines or overrides the given property.
* `has_property(property_name: String) -> bool` - Checks if the item has the given property.
* `get_property(property_name: String, default_value = null) -> Variant` - Returns the value of the property with the given name. In case the property can not be found, the default value is returned.
* `set_property(property_name: String, value) -> void` - Sets the property with the given name for this item.
* `clear_property(property_name: String) -> void` - Clears the property with the given name for this item.
* `reset() -> void` - Resets all properties to default values.
* `get_texture() -> Texture` - Helper function for retrieving the item texture. It checks the `image` item property and loads it as a texture, if available.
* `get_title() -> String` - Helper function for retrieving the item title. It checks the `name` item property and uses it as the title, if available. Otherwise, `prototype_id` is returned as title.
* `serialize() -> Dictionary` - Serializes the item into a dictionary.
* `deserialize(source: Dictionary) -> bool` - Deserializes the item from a given dictionary.
* `static func swap(item1: InventoryItem, item2: InventoryItem) -> bool` - Swaps the two given items contained in an `Inventory` or an `ItemSlot`. **NOTE:** In the current version only items of the same size can be swapped.

## Signals

* `protoset_changed` - Emitted when the item protoset changes.
* `prototype_id_changed` - Emitted when the item prototype ID changes.
* `properties_changed` - Emitted when the item properties change.
* `property_changed(property_name)` - Emitted when an item property has changed.