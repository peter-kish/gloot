# `InventoryItem`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Inventory item class. It is based on an item prototype from an [`ItemProtoset`](./item_protoset.md) resource. Can hold additional properties.

## Properties

* `protoset: Resource` - An `ItemProtoset` resource containing item prototypes.
* `prototype_id: String` - ID of the prototype from `protoset` this item is based on.
* `properties: Dictionary` - Additional item properties.

## Methods

* `get_inventory() -> Node` - Returns the `Inventory` this item belongs to.
* `get_property(property_name: String, default_value = null) -> Variant` - Returns the value of the property with the given name. In case the property can not be found, the default value is returned.
* `set_property(property_name: String, value) -> void` - Sets the property with the given name for this item.
* `clear_property(property_name: String) -> void` - Clears the property with the given name for this item.
* `reset() -> void` - Resets all properties to default values.
* `get_texture() -> Texture` - Helper function for retrieving the item texture. It checks the `image` item property and loads it as a texture, if available.
* `get_title() -> String` - Helper function for retrieving the item title. It checks the `name` item property and uses it as the title, if available. Otherwise, `prototype_id` is returned as title.
* `serialize() -> Dictionary` - Serializes the item into a dictionary.
* `deserialize(source: Dictionary) -> bool` - Deserializes the item from a given dictionary.