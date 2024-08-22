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


func _init(id: String) -> void:
    _id = id


## Returns the prototype ID string.
func get_id() -> String:
    return _id


## Checks if the prototype overrides the given property.
func overrides_property(property: String) -> bool:
    return _properties.has(property)


## Checks if the prototype has the given property defined.
func has_property(property: String) -> bool:
    if overrides_property(property):
        return true
    if is_instance_valid(_parent):
        return _parent.has_property(property)
    return false


## Returns the value of the given property. If the prototype does not have the property defined, `default_value` is
## returned.
func get_property(property: String, default_value: Variant = null) -> Variant:
    if _properties.has(property):
        return _properties[property]
    if is_instance_valid(_parent):
        return _parent.get_property(property)
    return default_value


## Returns a `Dictionary` of all properties defined for the prototype.
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
func has_prototype(prototype_id: String) -> bool:
    return get_prototype(prototype_id) != null


## Checks if the prototype with the given ID has the given property defined.
func has_prototype_property(prototype_id: String, property: String) -> bool:
    if !has_prototype(prototype_id):
        return false

    return get_prototype(prototype_id).has_property(property)


## Returns the given property of the prototype with the given ID. If the prototype does not have the property defined,
## `default_value` is returned.
func get_prototype_property(prototype_id: String, property: String, default_value: Variant = null) -> Variant:
    if has_prototype(prototype_id):
        var prototype = get_prototype(prototype_id)
        if !prototype._properties.is_empty() && prototype.has_property(property):
            return prototype.get_property(property)
    
    return default_value


## Creates a child prototype with the given ID.
func create_prototype(prototype_id: String) -> Prototype:
    # TODO: Consider using a prototype as input
    if has_prototype(prototype_id):
        return null
    var new_prototype := Prototype.new(prototype_id)
    new_prototype._parent = self
    _prototypes[prototype_id] = new_prototype
    return new_prototype


## Returns the prototype with the given ID.
func get_prototype(prototype_id: String) -> Prototype:
    if prototype_id.is_empty():
        return null
    if _prototypes.has(prototype_id):
        return _prototypes[prototype_id]
    for p in _prototypes:
        var prototype: Prototype = _prototypes[p].get_prototype(prototype_id)
        if is_instance_valid(prototype):
            return prototype
    return null


## Returns the ID of the prototype.
func get_prototype_id() -> String:
    return _id


func _is_root() -> bool:
    return !is_instance_valid(_parent)


## Returns an array of all child prototypes.
func get_prototypes() -> Array:
    return _prototypes.values().duplicate()


## Removes the prototype with the given ID.
func remove_prototype(prototype_id: String) -> void:
    var prototype = get_prototype(prototype_id)
    if prototype == null:
        return
    var parent = prototype._parent
    if parent == null:
        return
    parent._prototypes.erase(prototype.get_id())


func _get_root() -> Prototype:
    var root = self
    while is_instance_valid(root._parent):
        root = root._parent
    return root


## Clears the prototype by clearing its properties and removing all child prototypes.
func clear() -> void:
    _properties.clear()
    _prototypes.clear()
