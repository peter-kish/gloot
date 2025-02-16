class_name ProtoTree
extends RefCounted
## A prototype tree (prototree).
##
## A tree structure of prototypes with a root prototype that can have a number of child prototypes.

const _Utils = preload("res://addons/gloot/core/utils.gd")

var _root := Prototype.new("ROOT")


## Returns the root prototype.
func get_root() -> Prototype:
    return _root


## Creates a child prototype for the root prototype.
func create_prototype(prototype_id: String) -> Prototype:
    return _root.inherit(prototype_id)


## Returns the prototype with the given ID.
func get_prototype(prototype_id: String) -> Prototype:
    return _root.get_derived_prototype(prototype_id)


## Returns an array of all child prototypes of the root.
func get_prototypes() -> Array:
    return _root.get_derived_prototypes()


## Checks if the prototree contains the prototype with the given ID.
func has_prototype(prototype_id: String) -> bool:
    return _root._prototype_id_taken(prototype_id)


## Checks if the prototype with the given ID has the given property defined.
func prototype_has_property(prototype_id: String, property: String) -> bool:
    if !has_prototype(prototype_id):
        return false
    return _root.get_derived_prototype(prototype_id).has_property(property)


## Returns the given property of the prototype with the given ID. If the prototype does not have the property defined,
## `default_value` is returned.
func get_prototype_property(prototype_id: String, property: String, default_value: Variant = null) -> Variant:
    if has_prototype(prototype_id):
        var prototype = get_prototype(prototype_id)
        if prototype.has_property(property):
            return prototype.get_property(property)
    
    return default_value


## Clears the prototree by clearing the roots properties and child prototypes.
func clear() -> void:
    _root._clear()


## Checks if the prototree is empty (the root has no properties and no child prototypes).
func is_empty() -> bool:
    return _root.get_properties().is_empty() && _root.get_derived_prototypes().is_empty()


## Parses the given JSON resource into a prototree. Returns `false` if parsing fails.
func deserialize(json: JSON) -> bool:
    clear()
    if !is_instance_valid(json):
        return false
    if json.data == null:
        return false
    if json.data.is_empty():
        return true
    for prototype_id in json.data.keys():
        var base: Prototype = null
        var prototype_dict = json.data[prototype_id]
        if prototype_dict.has("inherits"):
            base = _root.get_derived_prototype(prototype_dict["inherits"])
        else:
            base = _root

        if base == null:
            clear()
            return false
        var new_protototype = base.inherit(prototype_id)
        assert(new_protototype)
        for property in prototype_dict.keys():
            if typeof(prototype_dict[property]) == TYPE_STRING:
                var value = _Utils.str_to_var(prototype_dict[property])
                if value == null:
                    new_protototype.set_property(property, prototype_dict[property])
                else:
                    new_protototype.set_property(property, value)
            else:
                new_protototype.set_property(property, prototype_dict[property])
    return true
