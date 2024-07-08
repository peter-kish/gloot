# `Prototype`

Inherits: `RefCounted`

## Description

An item prototype.

An item prototype contains a set of properties and is identified with an ID string. It can also contain other "child" prototypes as part of a prototype tree (prototree).

## Methods

* `clear() -> void` - Clears the prototype by clearing its properties and removing all child prototypes.
* `create_prototype(prototype_id: String) -> Prototype` - Creates a child prototype with the given ID.
* `get_id() -> String` - Returns the prototype ID string.
* `get_properties() -> Dictionary` - Returns a `Dictionary` of all properties defined for the prototype.
* `get_property(property: String, default_value: Variant) -> Variant` - Returns the value of the given property. If the prototype does not have the property defined, `default_value` is returned.
* `get_prototype(prototype_id: String) -> Prototype` - Returns the prototype with the given ID.
* `get_prototype_id() -> String` - Returns the ID of the prototype.
* `get_prototype_property(prototype_id: String, property: String, default_value: Variant) -> Variant` - Returns the given property of the prototype with the given ID. If the prototype does not have the property defined, `default_value` is returned.
* `get_prototypes() -> Array` - Returns an array of all child prototypes.
* `has_property(property: String) -> bool` - Checks if the prototype has the given property defined.
* `has_prototype(prototype_id: String) -> bool` - Checks if the prototype contains the prototype with the given ID within the prototype tree.
* `has_prototype_property(prototype_id: String, property: String) -> bool` - Checks if the prototype with the given ID has the given property defined.
* `overrides_property(property: String) -> bool` - Checks if the prototype overrides the given property.
* `remove_prototype(prototype_id: String) -> void` - Removes the prototype with the given ID.
* `set_property(property: String, value: Variant) -> void` - Sets the given property for the prototype.

