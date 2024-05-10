
class QtRect:
    var rect: Rect2i
    var metadata: Variant


    func _init(rect_: Rect2i, metadata_: Variant) -> void:
        rect = rect_
        metadata = metadata_

    
    func _to_string() -> String:
        return "[R: %s, M: %s]" % [str(rect), str(metadata)]


class QtNode:
    var quadrants: Array[QtNode] = [null, null, null, null]
    var qt_rects: Array[QtRect]
    var rect: Rect2i


    func _init(r: Rect2i) -> void:
        rect = r


    func is_empty() -> bool:
        for quadrant in quadrants:
            if quadrant != null:
                return false
        return qt_rects.is_empty()


    func get_first_under_rect(test_rect: Rect2i) -> QtRect:
        for qtr in qt_rects:
            if qtr.rect.intersects(test_rect):
                return qtr

        for quadrant in quadrants:
            if quadrant == null:
                continue
            if !quadrant.rect.intersects(test_rect):
                continue
            var first = quadrant.get_first_under_rect(test_rect)
            if first != null:
                return first

        return null


    func get_first_containing_point(point: Vector2i) -> QtRect:
        for qtr in qt_rects:
            if qtr.rect.has_point(point):
                return qtr

        for quadrant in quadrants:
            if quadrant == null:
                continue
            if !quadrant.rect.has_point(point):
                continue
            var first = quadrant.get_first_containing_point(point)
            if first != null:
                return first

        return null


    func get_all_under_rect(test_rect: Rect2i) -> Array[QtRect]:
        var result: Array[QtRect]

        for qtr in qt_rects:
            if qtr.rect.intersects(test_rect):
                result.append(qtr)

        for quadrant in quadrants:
            if quadrant == null:
                continue
            if !quadrant.rect.intersects(test_rect):
                continue
            result.append_array(quadrant.get_all_under_rect(test_rect))

        return result


    func get_all_containing_point(point: Vector2i) -> Array[QtRect]:
        var result: Array[QtRect]

        for qtr in qt_rects:
            if qtr.rect.has_point(point):
                result.append(qtr)

        for quadrant in quadrants:
            if quadrant == null:
                continue
            if !quadrant.rect.has_point(point):
                continue
            result.append_array(quadrant.get_all_containing_point(point))

        return result


    func add(qt_rect: QtRect) -> void:
        if !_can_subdivide(rect.size):
            qt_rects.append(qt_rect)
            return

        if is_empty():
            qt_rects.append(qt_rect)
            return

        var quadrant_rects := _get_quadrant_rects(rect)
        for i in quadrant_rects.size():
            var quadrant_rect := quadrant_rects[i]
            if !quadrant_rect.intersects(qt_rect.rect):
                continue
            if quadrants[i] == null:
                quadrants[i] = QtNode.new(quadrant_rect)
                while !qt_rects.is_empty():
                    var qtr = qt_rects.pop_back()
                    
                    add(qtr)
            quadrants[i].add(qt_rect)


    func remove(metadata: Variant) -> bool:
        # TODO: Optimize with a Rect2i
        var result = false
        for i in range(qt_rects.size() - 1, -1, -1):
            if qt_rects[i].metadata == metadata:
                qt_rects.remove_at(i)
                result = true

        for i in range(quadrants.size()):
            if quadrants[i] == null:
                continue
            if quadrants[i].remove(metadata):
                result = true
            if quadrants[i].is_empty():
                quadrants[i] = null

        _collapse()

        return result


    func _collapse() -> void:
        var collapsable_quadrant_idx = _get_collapsable_quadrant_idx()
        if collapsable_quadrant_idx < 0:
            return
        for qt_rect in quadrants[collapsable_quadrant_idx].qt_rects:
            qt_rects.append(qt_rect)
        quadrants[collapsable_quadrant_idx] = null


    func _get_collapsable_quadrant_idx() -> int:
        var result: int = -1
        for i in range(quadrants.size()):
            if quadrants[i] == null:
                continue
            if result >= 0:
                # More than 1 non-null quadrants
                return -1
            result = i

        if result < 0:
            # No non-null quadrants
            return -1
        if quadrants[result].qt_rects.size() > 1:
            # Quadrant contains more than 1 rects
            return -1

        return result


    static func _can_subdivide(size: Vector2i) -> bool:
        return size.x > 1 && size.y > 1


    #  +----+---+
    #  | 0  | 1 |
    #  |    |   |
    #  +----+---+ (the first quadrant is rounded up when the size is odd)
    #  | 2  | 3 |
    #  +----+---+
    static func _get_quadrant_rects(rect: Rect2i) -> Array[Rect2i]:
        var q0w := roundi(float(rect.size.x) / 2.0)
        var q0h := roundi(float(rect.size.y) / 2.0)
        var q0 := Rect2i(rect.position, Vector2i(q0w, q0h))
        var q3 := Rect2i(rect.position + q0.size, rect.size - q0.size)
        var q1 := Rect2i(Vector2i(q3.position.x, q0.position.y), Vector2i(q3.size.x, q0.size.y))
        var q2 := Rect2i(Vector2i(q0.position.x, q3.position.y), Vector2i(q0.size.x, q3.size.y))
        return [q0, q1, q2, q3]


var _root: QtNode
var _size: Vector2i


func _init(size: Vector2) -> void:
    assert(size.x > 1)
    assert(size.y > 1)
    _size = size
    _root = QtNode.new(Rect2i(Vector2i.ZERO, _size))


func get_first(at: Variant) -> QtRect:
    assert(at is Rect2i || at is Vector2i)
    if at is Rect2i:
        return _root.get_first_under_rect(at)
    if at is Vector2i:
        return _root.get_first_containing_point(at)
    return null


func get_all(at: Variant) -> Array[QtRect]:
    assert(at is Rect2i || at is Vector2i)
    if at is Rect2i:
        return _root.get_all_under_rect(at)
    if at is Vector2i:
        return _root.get_all_containing_point(at)
    return []


func add(qt_rect: QtRect) -> void:
    _root.add(qt_rect)


func remove(metadata: Variant) -> bool:
    return _root.remove(metadata)


func is_empty() -> bool:
    return _root.is_empty()
