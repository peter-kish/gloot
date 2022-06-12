# `ItemProtoset`

Inherits: [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html)

## Description

A resource type holding a set of inventory item prototypes in JSON format.

## Properties

* `json_data: String`
* `prototypes: Dictionary`

## Methods

* `parse(json: String)`
* `get(id: String) -> Dictionary`
* `has(id: String) -> bool`
* `empty() -> bool`
* `get_item_property(id: String, property_name: String, default_value)`
