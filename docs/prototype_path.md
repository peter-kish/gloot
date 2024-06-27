# `PrototypePath`

Inherits: `RefCounted`

## Description

A pre-parsed prototype path.

A pre-parsed relative or absolute path of a prototype within a prototype tree (prototree).

## Methods

* `equal(other: PrototypePath) -> bool` - Checks if the prototype path is equal to the given prototype path.
* `get_name(idx: int) -> StringName` - Gets the prototype path component name indicated by `idx`.
* `get_name_count() -> int` - Gets the number of path component names which make up the prototype path.
* `is_absolute() -> bool` - Checks if the path is absolute.
* `is_empty() -> bool` - Checks if the prototype path is empty.
* `str_paths_equal(path1: String, path2: String) -> bool` - Checks if the two prototype paths are equal (in string format).

