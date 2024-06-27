# `ProtoTree`

Inherits: `RefCounted`

## Description

A prototype tree (prototree).

A tree structure of prototypes with a root prototype that can have a number of child prototypes.

## Methods

* `clear() -> void` - Clears the prototree by clearing the roots properties and child prototypes.
* `create_prototype(prototype_id: String) -> Prototype` - Creates a child prototype for the root prototype.
* `deserialize(json: JSON) -> bool` - Parses the given JSON resource into a prototree. Returns `false` if parsing fails.
* `get_prototype(path: Variant) -> Prototype` - Returns the prototype at the given path (as a `String` or a `PrototypePath`).
* `get_prototype_property(path: Variant, property: String, default_value: Variant) -> Variant` - Returns the given property of the prototype at the given path (as a `String` or a `PrototypePath`). If the prototype does not have the property defined, `default_value` is returned.
* `get_prototypes() -> Array` - Returns an array of all child prototypes of the root.
* `get_root() -> Prototype` - Returns the root prototype.
* `has_prototype(path: Variant) -> bool` - Checks if the prototree contains the prototype at the given path (as a `String` or a `PrototypePath`).
* `has_prototype_property(path: Variant, property: String) -> bool` - Checks if the prototype at the given path (as a `String` or a `PrototypePath`) has the given property defined.
* `is_empty() -> bool` - Checks if the prototree is empty (the root has no properties and no child prototypes).

