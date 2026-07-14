extends TestSuite

const OccupancyMap = preload("res://addons/gloot/core/constraints/occupancy_map.gd")

func init_suite() -> void:
    tests = [
        "constructor_test",
        "add_test",
        "remove_test",
        "get_first_test",
        "get_all_test",
    ]


func constructor_test() -> void:
    var occupancy_map := OccupancyMap.new(Vector2i(42, 42))
    assert(occupancy_map._size == Vector2i(42, 42))


func add_test() -> void:
    var occupancy_map := OccupancyMap.new(Vector2i(4, 4))
    occupancy_map.add(Rect2i(0, 0, 1, 1), 42)
    assert(!occupancy_map.is_empty())
    assert(occupancy_map._data[0][0] == 42)
    assert(occupancy_map._data[1][1] == null)

    occupancy_map.add(Rect2i(1, 1, 1, 1), 43)
    assert(!occupancy_map.is_empty())
    assert(occupancy_map._data[1][1] == 43)


func remove_test() -> void:
    var occupancy_map := OccupancyMap.new(Vector2i(4, 4))
    occupancy_map.add(Rect2i(0, 0, 1, 1), 42)
    occupancy_map.add(Rect2i(1, 1, 1, 1), 43)
    occupancy_map.remove(42)
    assert(occupancy_map._data[0][0] == null)
    assert(occupancy_map._data[1][1] == 43)


func get_first_test() -> void:
    var occupancy_map := OccupancyMap.new(Vector2i(4, 4))
    occupancy_map.add(Rect2i(0, 0, 1, 1), 42)
    occupancy_map.add(Rect2i(1, 1, 1, 1), 43)

    var first: Variant = occupancy_map.get_first(Rect2i(0, 0, 2, 2))
    assert(first == 42)

    first = occupancy_map.get_first(Rect2i(0, 0, 2, 2), 42)
    assert(first == 43)
    
    first = occupancy_map.get_first(Vector2i(0, 0))
    assert(first == 42)

    first = occupancy_map.get_first(Vector2i(0, 0), 42)
    assert(first == null)


func get_all_test() -> void:
    var occupancy_map := OccupancyMap.new(Vector2i(4, 4))
    occupancy_map.add(Rect2i(0, 0, 1, 1), 42)
    occupancy_map.add(Rect2i(1, 1, 1, 1), 43)

    var all: Array[Variant] = occupancy_map.get_all(Rect2i(0, 0, 2, 2))
    assert(all.size() == 2)
    assert(all[0] == 42)
    assert(all[1] == 43)

    all = occupancy_map.get_all(Vector2i(1, 1))
    assert(all.size() == 1)
    assert(all[0] == 43)
