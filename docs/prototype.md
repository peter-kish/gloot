# `Prototype`

Inherits: `RefCounted`

## Description

An item prototype.

An item prototype contains a set of properties and is identified with an ID string. It can also contain other "child" prototypes as part of a prototype tree (prototree).

## Properties


## Methods

* `clear() -> void` - Clears the prototype by clearing its properties and removing all child prototypes.
* `create_prototype(prototype_id: String) -> Prototype` - Creates a child prototype with the given ID.
* `deserialize(json: JSON) -> bool` - Parses the given JSON resource into a prototype. Returns `false` if parsing fails.
* `get_id() -> String` - Returns the prototype ID string.
* `get_path() -> PrototypePath` - Returns the path of the prototype within the prototype tree.
* `get_properties() -> Dictionary` - Returns a `Dictionary` of all properties defined for the prototype.
* `get_property(property: String, default_value: Variant) -> Variant` - Returns the value of the given property. If the prototype does not have the property defined, `default_value` is returned.
* `get_prototype(path: Variant) -> Prototype` - Returns the prototype at the given path (as a `String` or a `PrototypePath`).
* `get_prototype_property(path: Variant, property: String, default_value: Variant) -> Variant` - Returns the given property of the prototype at the given path (as a `String` or a `PrototypePath`). If the prototype does not have the property defined, `default_value` is returned.
* `get_prototypes() -> Array` - Returns an array of all child prototypes.
* `has_property(property: String) -> bool` - Checks if the prototype has the given property defined.
* `has_prototype(path: Variant) -> bool` - Checks if the prototype contains the prototype at the given path (as a `String` or a `PrototypePath`) within the prototype tree.
* `has_prototype_property(path: Variant, property: String) -> bool` - Checks if the prototype at the given path (as a `String` or a `PrototypePath`) has the given property defined.
* `overrides_property(property: String) -> bool` - Checks if the prototype overrides the given property.
* `remove_prototype(path: Variant) -> void` - Removes the prototype at the given path (as a `String` or a `PrototypePath`).
* `set_property(property: String, value: Variant) -> void` - Sets the given property for the prototype.

