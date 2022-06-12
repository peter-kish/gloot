# `InventoryItem`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Inventory item class. It is based on an item prototype from an [`ItemProtoset`](./item_protoset.md) resource. Can hold additional properties.

## Properties

* `protoset: resource`
* `prototype_id: String`
* `properties: Dictionary`

## Methods

* `get_inventory() -> Node`
* `get_property(property_name: String, default_value = null) -> Variant`
* `set_property(property_name: String, value) -> void`
* `clear_property(property_name: String) -> void`