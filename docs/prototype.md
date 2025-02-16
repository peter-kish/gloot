# `Prototype`

Inherits: `RefCounted`

## Description

An item prototype.

An item prototype contains a set of properties and is identified with an ID string. It can also contain other "child" prototypes as part of a prototype tree (prototree).

## Methods

* `get_id() -> String` - Returns the prototype ID string.
* `inherits(prototype_id: String) -> bool` - Checks if the prototype inherits the prototype with the given ID.
* `inherits_property(property: String) -> bool` - Checks if the prototype inherits the given property.
* `defines_property(property: String) -> bool` - Checks if the prototype defines the given property.
* `overrides_property(property: String) -> bool` - Checks if the prototype overrides the given property.
* `has_property(property: String) -> bool` - Checks if the prototype has the given property (either by defining, inheriting or overriding it).
* `get_property(property: String, default_value: Variant) -> Variant` - Returns the value of the given property. If the prototype does not have the property, `default_value` is returned.
* `get_properties() -> Dictionary` - Returns a `Dictionary` of all prototype properties (defined, inherited or overridden).
* `set_property(property: String, value: Variant) -> void` - Sets the given property for the prototype.
* `is_inherited_by(prototype_id: String) -> bool` - Checks if the prototype contains the prototype with the given ID within the prototype tree.
* `inherit(prototype_id: String) -> Prototype` - Creates a child prototype with the given ID that inherits the prototype.
* `get_derived_prototype(prototype_id: String) -> Prototype` - Returns the derived prototype with the given ID.
* `get_prototype_id() -> String` - Returns the ID of the prototype.
* `get_derived_prototypes() -> Array` - Returns an array of all derived prototypes.

