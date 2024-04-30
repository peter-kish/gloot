class_name ProtoTree
extends RefCounted

var _root := Prototype.new("ROOT")


func get_root() -> Prototype:
    return _root


func create_prototype(prototype_id: String) -> Prototype:
    return _root.create_prototype(prototype_id)


func get_prototype(path) -> Prototype:
    return _root.get_prototype(path)


func get_prototypes() -> Array:
    return _root.get_prototypes()


func has_prototype(path) -> bool:
    return _root.has_prototype(path)


func has_prototype_property(path: Variant, property: String) -> bool:
    return _root.has_prototype_property(path, property)


func get_prototype_property(path: Variant, property: String, default_value: Variant = null) -> Variant:
    return _root.get_prototype_property(path, property, default_value)


func clear() -> void:
    _root.clear()


func is_empty() -> bool:
    return _root.get_properties().is_empty() && _root.get_prototypes().is_empty()


func deserialize(json: JSON) -> bool:
    return _root.deserialize(json)

