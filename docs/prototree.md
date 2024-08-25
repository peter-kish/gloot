# `ProtoTree`

Inherits: `RefCounted`

## Description

A prototype tree (prototree).

A tree structure of prototypes with a root prototype that can have a number of child prototypes.

## Methods

* `get_root() -> Prototype` - Returns the root prototype.
* `create_prototype(prototype_id: String) -> Prototype` - Creates a child prototype for the root prototype.
* `get_prototype(prototype_id: String) -> Prototype` - Returns the prototype with the given ID.
* `get_prototypes() -> Array` - Returns an array of all child prototypes of the root.
* `has_prototype(prototype_id: String) -> bool` - Checks if the prototree contains the prototype with the given ID.
* `prototype_has_property(prototype_id: String, property: String) -> bool` - Checks if the prototype with the given ID has the given property defined.
* `get_prototype_property(prototype_id: String, property: String, default_value: Variant) -> Variant` - Returns the given property of the prototype with the given ID. If the prototype does not have the property defined, `default_value` is returned.
* `clear() -> void` - Clears the prototree by clearing the roots properties and child prototypes.
* `is_empty() -> bool` - Checks if the prototree is empty (the root has no properties and no child prototypes).
* `deserialize(json: JSON) -> bool` - Parses the given JSON resource into a prototree. Returns `false` if parsing fails.

