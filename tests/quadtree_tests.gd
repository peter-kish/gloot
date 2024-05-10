extends TestSuite

const QuadTree = preload("res://addons/gloot/core/constraints/quadtree.gd")

func init_suite() -> void:
    tests = [
        "can_subdivide_test",
        "get_quadrant_rects_test",
        "constructor_test",
        "add_test",
        "remove_test",
        "get_first_test",
        "get_all_test",
    ]


func can_subdivide_test() -> void:
    assert(QuadTree.QtNode._can_subdivide(Vector2i(2, 2)))
    assert(QuadTree.QtNode._can_subdivide(Vector2i(5, 5)))
    assert(!QuadTree.QtNode._can_subdivide(Vector2i(1, 5)))
    assert(!QuadTree.QtNode._can_subdivide(Vector2i(5, 1)))
    assert(!QuadTree.QtNode._can_subdivide(Vector2i(1, 1)))


func get_quadrant_rects_test() -> void:
    var test_data := [
        {input = Rect2i(0, 0, 2, 2), expected = [Rect2i(0, 0, 1, 1), Rect2i(1, 0, 1, 1), Rect2i(0, 1, 1, 1), Rect2i(1, 1, 1, 1)]},
        {input = Rect2i(0, 0, 5, 5), expected = [Rect2i(0, 0, 3, 3), Rect2i(3, 0, 2, 3), Rect2i(0, 3, 3, 2), Rect2i(3, 3, 2, 2)]},
        {input = Rect2i(2, 2, 4, 4), expected = [Rect2i(2, 2, 2, 2), Rect2i(4, 2, 2, 2), Rect2i(2, 4, 2, 2), Rect2i(4, 4, 2, 2)]},
        {input = Rect2i(2, 2, 5, 5), expected = [Rect2i(2, 2, 3, 3), Rect2i(5, 2, 2, 3), Rect2i(2, 5, 3, 2), Rect2i(5, 5, 2, 2)]},
    ]

    for data in test_data:
        var quadrant_rects := QuadTree.QtNode._get_quadrant_rects(data.input)
        for i in range(quadrant_rects.size()):
            assert(quadrant_rects[i] == data.expected[i])


func constructor_test() -> void:
    var quadtree := QuadTree.new(Vector2i(42, 42))
    assert(quadtree._size == Vector2i(42, 42))


func add_test() -> void:
    var quadtree := QuadTree.new(Vector2i(4, 4))
    quadtree.add(Rect2i(0, 0, 1, 1), 42)
    assert(!quadtree.is_empty())
    assert(quadtree._root.qt_rects.size() == 1)
    assert(quadtree._root.quadrants[0] == null)
    assert(quadtree._root.quadrants[1] == null)
    assert(quadtree._root.quadrants[2] == null)
    assert(quadtree._root.quadrants[3] == null)

    quadtree.add(Rect2i(1, 1, 1, 1), 43)
    assert(!quadtree.is_empty())
    assert(quadtree._root.qt_rects.is_empty())
    assert(quadtree._root.quadrants[0] != null)
    assert(quadtree._root.quadrants[0].qt_rects.is_empty())
    assert(quadtree._root.quadrants[0].quadrants[0].qt_rects.size() == 1)
    assert(quadtree._root.quadrants[0].quadrants[1] == null)
    assert(quadtree._root.quadrants[0].quadrants[2] == null)
    assert(quadtree._root.quadrants[0].quadrants[3].qt_rects.size() == 1)
    assert(quadtree._root.quadrants[1] == null)
    assert(quadtree._root.quadrants[2] == null)
    assert(quadtree._root.quadrants[3] == null)


func remove_test() -> void:
    var quadtree := QuadTree.new(Vector2i(4, 4))
    quadtree.add(Rect2i(0, 0, 1, 1), 42)
    quadtree.add(Rect2i(1, 1, 1, 1), 43)
    quadtree.remove(42)
    assert(quadtree._root.quadrants[0] == null)
    assert(quadtree._root.quadrants[1] == null)
    assert(quadtree._root.quadrants[2] == null)
    assert(quadtree._root.quadrants[3] == null)
    assert(quadtree._root.qt_rects.size() == 1)
    assert(quadtree._root.qt_rects[0].metadata == 43)


func get_first_test() -> void:
    var quadtree := QuadTree.new(Vector2i(4, 4))
    quadtree.add(Rect2i(0, 0, 1, 1), 42)
    quadtree.add(Rect2i(1, 1, 1, 1), 43)

    var first := quadtree.get_first(Rect2i(0, 0, 2, 2))
    assert(first != null)
    assert(first.rect == Rect2i(0, 0, 1, 1))
    assert(first.metadata == 42)

    first = quadtree.get_first(Rect2i(0, 0, 2, 2), 42)
    assert(first != null)
    assert(first.rect == Rect2i(1, 1, 1, 1))
    assert(first.metadata == 43)
    
    first = quadtree.get_first(Vector2i(0, 0))
    assert(first != null)
    assert(first.rect == Rect2i(0, 0, 1, 1))
    assert(first.metadata == 42)

    first = quadtree.get_first(Vector2i(0, 0), 42)
    assert(first == null)


func get_all_test() -> void:
    var quadtree := QuadTree.new(Vector2i(4, 4))
    quadtree.add(Rect2i(0, 0, 1, 1), 42)
    quadtree.add(Rect2i(1, 1, 1, 1), 43)

    var all := quadtree.get_all(Rect2i(0, 0, 2, 2))
    assert(all.size() == 2)
    assert(all[0].rect == Rect2i(0, 0, 1, 1))
    assert(all[0].metadata == 42)
    assert(all[1].rect == Rect2i(1, 1, 1, 1))
    assert(all[1].metadata == 43)

    all = quadtree.get_all(Vector2i(1, 1))
    assert(all.size() == 1)
    assert(all[0].rect == Rect2i(1, 1, 1, 1))
    assert(all[0].metadata == 43)
