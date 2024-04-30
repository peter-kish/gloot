class_name Prototype
extends RefCounted

const KEY_PROPERTIES = "properties"
const KEY_PROTOTYPES = "prototypes"

var _id: String
var _properties: Dictionary
var _parent: Prototype
var _prototypes: Dictionary


func _init(id: String) -> void:
    _id = id


func get_id() -> String:
    return _id


func overrides_property(property: String) -> bool:
    return _properties.has(property)


func has_property(property: String) -> bool:
    if overrides_property(property):
        return true
    if is_instance_valid(_parent):
        return _parent.has_property(property)
    return false


func get_property(property: String) -> Variant:
    if _properties.has(property):
        return _properties[property]
    if is_instance_valid(_parent):
        return _parent.get_property(property)
    return null


func get_properties() -> Dictionary:
    var result := _properties.duplicate()
    if !is_instance_valid(_parent):
        return result

    result.merge(_parent.get_properties())
    return result


func set_property(property: String, value: Variant):
    if get_property(property) == value:
        return
    _properties[property] = value


func has_prototype(path) -> bool:
    path = _to_path(path)
    return get_prototype(path) != null


func has_prototype_property(path: Variant, property: String) -> bool:
    if !has_prototype(path):
        return false

    return get_prototype(path).has_property(property)


func get_prototype_property(path: Variant, property: String, default_value: Variant = null) -> Variant:
    if has_prototype(path):
        var prototype = get_prototype(path)
        if !prototype._properties.is_empty() && prototype.has_property(property):
            return prototype.get_property(property)
    
    return default_value


func create_prototype(prototype_id: String) -> Prototype:
    # TODO: Consider using a prototype path as input
    # TODO: Consider using a prototype as input
    if has_prototype(PrototypePath.new(prototype_id)):
        return null
    var new_prototype := Prototype.new(prototype_id)
    new_prototype._parent = self
    _prototypes[prototype_id] = new_prototype
    return new_prototype


func get_prototype(path) -> Prototype:
    path = _to_path(path)
    if path.is_empty():
        return null
    var prototype = self
    if path.is_absolute():
        prototype = _get_root()
    for i in range(path.get_name_count()):
        if !prototype._prototypes.has(str(path.get_name(i))):
            return null
        prototype = prototype._prototypes[str(path.get_name(i))]
    return prototype


func get_path() -> PrototypePath:
    return PrototypePath.new(_get_str_path())


func _get_str_path() -> String:
    if _is_root():
        return PrototypePath.DELIMITER
    return "%s/%s" % [_parent._get_str_path(), get_id()]


func _is_root() -> bool:
    return !is_instance_valid(_parent)


func get_prototypes() -> Array:
    return _prototypes.values().duplicate()


func remove_prototype(path) -> void:
    path = _to_path(path)
    var prototype = get_prototype(path)
    if prototype == null:
        return
    var parent = prototype._parent
    if parent == null:
        return
    parent._prototypes.erase(prototype.get_id())


func _to_path(path)-> PrototypePath:
    if path is String:
        return PrototypePath.new(path)
    if path is PrototypePath:
        return path
    push_error("Can't convert parameter to PrototypePath")
    return null


func _get_root() -> Prototype:
    var root = self
    while is_instance_valid(root._parent):
        root = root._parent
    return root


func clear() -> void:
    _properties.clear()
    _prototypes.clear()


func deserialize(json: JSON) -> bool:
    clear()
    if !is_instance_valid(json):
        return false
    return _deserialize_from_dict(json.data)


func _deserialize_from_dict(data: Dictionary) -> bool:
    # TODO: data verification
    if data.is_empty():
        return true
    if data.has(KEY_PROPERTIES):
        for property in data[KEY_PROPERTIES].keys():
            if typeof(data[KEY_PROPERTIES][property]) == TYPE_STRING:
                var value = str_to_var(data[KEY_PROPERTIES][property])
                if value == null:
                    set_property(property, data[KEY_PROPERTIES][property])
                else:
                    set_property(property, value)
            else:
                set_property(property, data[KEY_PROPERTIES][property])
    if data.has(KEY_PROTOTYPES):
        for prototype_id in data[KEY_PROTOTYPES].keys():
            var new_protototype := create_prototype(prototype_id)
            if !new_protototype._deserialize_from_dict(data[KEY_PROTOTYPES][prototype_id]):
                return false
    return true
