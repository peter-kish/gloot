class_name PrototypePath
extends RefCounted

const DELIMITER = "/"
var _path: PackedStringArray
var _absolute: bool = false


func _init(path: String) -> void:
    path = path.strip_edges()
    if path.is_empty():
        return
    _absolute = (path[0] == DELIMITER)
    _path = path.split(DELIMITER, false)
    for i in _path.size():
        _path[i] = _path[i].strip_edges()


func is_absolute() -> bool:
    return _absolute


func get_name_count() -> int:
    return _path.size()


func get_name(idx: int) -> StringName:
    return _path[idx]


func is_empty() -> bool:
    return _path.is_empty()


func equal(other: PrototypePath) -> bool:
    if _path.size() != other._path.size():
        return false
    if _absolute != other._absolute:
        return false

    for i in range(_path.size()):
        if _path[i] != other._path[i]:
            return false
    return true


static func str_paths_equal(path1: String, path2: String) -> bool:
    var p1 := PrototypePath.new(path1)
    var p2 := PrototypePath.new(path2)
    return p1.equal(p2)


func _to_string() -> String:
    var result: String = ""
    if _absolute:
        result = DELIMITER

    for i in range(0, _path.size()):
        if i != 0:
            result = "%s%s" % [result, DELIMITER]
        result = "%s%s" % [result, _path[i]]
    return result
