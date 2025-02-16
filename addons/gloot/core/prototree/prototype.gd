class_name Prototype
extends RefCounted
## An item prototype.
##
## An item prototype contains a set of properties and is identified with an ID string. It can also contain other "child"
## prototypes as part of a prototype tree (prototree).

const _KEY_PROPERTIES = "properties"
const _KEY_PROTOTYPES = "prototypes"

var _id: String
var _properties: Dictionary
var _parent: Prototype
var _prototypes: Dictionary
var _all_prototypes: Dictionary
var _root: Prototype


func _init(id: String) -> void:
    _id = id


## Returns the prototype ID string.
func get_id() -> String:
    return _id


## Checks if the prototype inherits the prototype with the given ID.
func inherits(prototype_id: String) -> bool:
    assert(_prototype_id_taken(prototype_id), "Prototype '%s' not found!" % prototype_id)

    var x = self
    while x:
        if x._id == prototype_id:
            return true
        x = x._parent
    return false


func _defines_or_overrides_property(property: String) -> bool:
    return _properties.has(property)


## Checks if the prototype inherits the given property.
func inherits_property(property: String) -> bool:
    if is_instance_valid(_parent):
        return _parent.has_property(property)
    return false


## Checks if the prototype defines the given property.
func defines_property(property: String) -> bool:
    return _defines_or_overrides_property(property) && !inherits_property(property)


## Checks if the prototype overrides the given property.
func overrides_property(property: String) -> bool:
    return _defines_or_overrides_property(property) && inherits_property(property)


## Checks if the prototype has the given property (either by defining, inheriting or overriding it).
func has_property(property: String) -> bool:
    if _defines_or_overrides_property(property):
        return true
    if is_instance_valid(_parent):
        return _parent.has_property(property)
    return false


## Returns the value of the given property. If the prototype does not have the property, `default_value` is returned.
func get_property(property: String, default_value: Variant = null) -> Variant:
    if _properties.has(property):
        return _properties[property]
    if is_instance_valid(_parent):
        return _parent.get_property(property, default_value)
    return default_value


## Returns a `Dictionary` of all prototype properties (defined, inherited or overridden).
func get_properties() -> Dictionary:
    var result := _properties.duplicate()
    if !is_instance_valid(_parent):
        return result

    result.merge(_parent.get_properties())
    return result


## Sets the given property for the prototype.
func set_property(property: String, value: Variant):
    if get_property(property) == value:
        return
    _properties[property] = value


## Checks if the prototype contains the prototype with the given ID within the prototype tree.
func is_inherited_by(prototype_id: String) -> bool:
    return _find_derived_prototype(prototype_id) != null


## Creates a child prototype with the given ID that inherits the prototype.
func inherit(prototype_id: String) -> Prototype:
    # TODO: Consider using a prototype as input
    assert(!_prototype_id_taken(prototype_id), "Prototype '%s' already defined!" % prototype_id)
    var new_prototype := Prototype.new(prototype_id)
    new_prototype._parent = self
    if _root:
        new_prototype._root = _root
    else:
        new_prototype._root = self

    _prototypes[prototype_id] = new_prototype
    new_prototype._root._all_prototypes[prototype_id] = new_prototype

    return new_prototype


## Returns the derived prototype with the given ID.
func get_derived_prototype(prototype_id: String) -> Prototype:
    assert(!prototype_id.is_empty(), "Invalid prototype ID (empty string)!")
    var result := _find_derived_prototype(prototype_id)
    assert(result != null, "Derived prototype not found: '%s'" % prototype_id)
    return result


func _find_derived_prototype(prototype_id: String) -> Prototype:
    assert(_prototype_id_taken(prototype_id), "Prototype '%s' not found!" % prototype_id)
    if _prototypes.has(prototype_id):
        return _prototypes[prototype_id]
    for p in _prototypes:
        var prototype: Prototype = _prototypes[p]._find_derived_prototype(prototype_id)
        if is_instance_valid(prototype):
            return prototype
    return null


## Returns the ID of the prototype.
func get_prototype_id() -> String:
    return _id


func _is_root() -> bool:
    return !is_instance_valid(_parent)


## Returns an array of all derived prototypes.
func get_derived_prototypes() -> Array:
    return _prototypes.values().duplicate()


func _prototype_id_taken(prototype_id: String) -> bool:
    if _root:
        if prototype_id == _root._id:
            return true
        return _root._all_prototypes.has(prototype_id)
    else:
        return _all_prototypes.has(prototype_id)


func _clear() -> void:
    _properties.clear()
    _prototypes.clear()
    _all_prototypes.clear()
