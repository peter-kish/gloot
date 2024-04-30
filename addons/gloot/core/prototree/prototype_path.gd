class_name PrototypePath
extends RefCounted

const DELIMITER = "/"
var _path: PackedStringArray
var _absolute: bool


func _init(path: String) -> void:
    _path = path.split(DELIMITER, false)
    _absolute = (path[0] == DELIMITER)


func is_absolute() -> bool:
    return _absolute


func get_name_count() -> int:
    return _path.size()


func get_name(idx: int) -> StringName:
    return _path[idx]


func is_empty() -> bool:
    return _path.is_empty()


func _to_string() -> String:
    var result: String = ""
    if _absolute:
        result = DELIMITER

    for i in range(0, _path.size()):
        if i != 0:
            result = "%s%s" % [result, DELIMITER]
        result = "%s%s" % [result, _path[i]]
    return result
