var _size: Vector2i
var _data: Array[Array]


func _init(size: Vector2i) -> void:
    assert(size.x > 0, "Size must be positive")
    assert(size.y > 0, "Size must be positive")
    _size = size
    _data.resize(size.x)
    for x in _data.size():
        _data[x] = Array()
        _data[x].resize(size.y)
        for y in _data[x].size():
            _data[x][y] = null


func get_first(at: Variant, exception: Variant = null) -> Variant:
    assert(at is Rect2i || at is Vector2i)
    if at is Rect2i:
        return _get_first_under_rect(at, exception)
    if at is Vector2i:
        return _get_first_containing_point(at, exception)
    return null


func _get_first_under_rect(rect: Rect2i, exception: Variant = null) -> Variant:
    assert(Rect2(Vector2i.ZERO, _size).encloses(rect), "Rect out of bounds")
    for i in rect.size.x:
        for j in rect.size.y:
            var value = _data[rect.position.x + i][rect.position.y + j]
            if value and value != exception:
                return value
    return null


func _get_first_containing_point(at: Vector2i, exception: Variant = null) -> Variant:
    assert(Rect2(Vector2i.ZERO, _size).has_point(at), "Point out of bounds")
    var value = _data[at.x][at.y]
    if value == exception:
        return null
    return value


func get_all(at: Variant, exception: Variant = null) -> Array[Variant]:
    assert(at is Rect2i || at is Vector2i)
    if at is Rect2i:
        return _get_all_under_rect(at, exception)
    if at is Vector2i:
        return [_get_first_containing_point(at, exception)]
    return []


func _get_all_under_rect(rect: Rect2i, exception: Variant = null) -> Array[Variant]:
    assert(Rect2(Vector2i.ZERO, _size).encloses(rect), "Rect out of bounds")
    var result := []
    for i in rect.size.x:
        for j in rect.size.y:
            var field = _data[rect.position.x + i][rect.position.y + j]
            if field:
                result.append(field)
    return result


func add(rect: Rect2i, metadata: Variant) -> void:
    assert(Rect2(Vector2i.ZERO, _size).encloses(rect), "Rect out of bounds")
    assert(rect.position.x >= 0, "Rect position must be greater or equal than zero")
    assert(rect.position.y >= 0, "Rect position must be greater or equal than zero")
    assert(rect.size.x > 0, "Rect size must be positive")
    assert(rect.size.y > 0, "Rect size must be positive")
    for i in rect.size.x:
        for j in rect.size.y:
            _data[rect.position.x + i][rect.position.y + j] = metadata


func remove(metadata: Variant) -> bool:
    var removed := false
    for i in _size.x:
        for j in _size.y:
            if _data[i][j] == metadata:
                _data[i][j] = null
                removed = false
    return removed
    

func is_empty() -> bool:
    for i in _size.x:
        for j in _size.y:
            if _data[i][j]:
                return false
    return true
