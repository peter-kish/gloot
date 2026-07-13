extends TestSuite

const QuadTree = preload("res://addons/gloot/core/constraints/quadtree.gd")
const OccupancyMap = preload("res://addons/gloot/core/constraints/occupancy_map.gd")
const STRESS_TEST_MAP_SIZE: Vector2i = Vector2i(100, 100)
const STRESS_TEST_N_CHECKS: int = 100


func init_suite() -> void:
    tests = [
        "quadtree_big_element_test",
        "quadtree_small_element_test",
        "occupancy_map_big_element_test",
        "occupancy_map_small_element_test",
        "autosplitmerge_stress_test",
    ]


func quadtree_big_element_test() -> void:
    var start_time_msec := Time.get_ticks_usec()
    var quadtree := QuadTree.new(STRESS_TEST_MAP_SIZE)
    @warning_ignore("integer_division")
    quadtree.add(Rect2i(Vector2i.ZERO, STRESS_TEST_MAP_SIZE / 2), "big_element")
    for i in STRESS_TEST_N_CHECKS:
        quadtree.get_first(Vector2i(randi_range(0, 99), randi_range(0, 99)))
    var end_time_msec := Time.get_ticks_usec()
    print("Quadtree Stress Test - big element: %dus" % (end_time_msec - start_time_msec))


func quadtree_small_element_test() -> void:
    var start_time_msec := Time.get_ticks_usec()
    var quadtree := QuadTree.new(STRESS_TEST_MAP_SIZE)
    for i in STRESS_TEST_MAP_SIZE.x:
        for j in STRESS_TEST_MAP_SIZE.y:
            quadtree.add(Rect2i(i, j, 1, 1), "element_%d_%d" % [i, j])
    for i in STRESS_TEST_N_CHECKS:
        quadtree.get_first(Vector2i(randi_range(0, 99), randi_range(0, 99)))
    var end_time_msec := Time.get_ticks_usec()
    print("Quadtree Stress Test - small element: %dus" % (end_time_msec - start_time_msec))


func occupancy_map_big_element_test() -> void:
    var start_time_msec := Time.get_ticks_usec()
    var occupancy_map := OccupancyMap.new(STRESS_TEST_MAP_SIZE)
    @warning_ignore("integer_division")
    occupancy_map.add(Rect2i(Vector2i.ZERO, STRESS_TEST_MAP_SIZE / 2), "big_element")
    for i in STRESS_TEST_N_CHECKS:
        occupancy_map.get_first(Vector2i(randi_range(0, 99), randi_range(0, 99)))
    var end_time_msec := Time.get_ticks_usec()
    print("Occupancy Map Stress Test - big element: %dus" % (end_time_msec - start_time_msec))


func occupancy_map_small_element_test() -> void:
    var start_time_msec := Time.get_ticks_usec()
    var occupancy_map := OccupancyMap.new(STRESS_TEST_MAP_SIZE)
    for i in STRESS_TEST_MAP_SIZE.x:
        for j in STRESS_TEST_MAP_SIZE.y:
            occupancy_map.add(Rect2i(i, j, 1, 1), "element_%d_%d" % [i, j])
    for i in STRESS_TEST_N_CHECKS:
        occupancy_map.get_first(Vector2i(randi_range(0, 99), randi_range(0, 99)))
    var end_time_msec := Time.get_ticks_usec()
    print("Occupancy Map Stress Test - small element: %dus" % (end_time_msec - start_time_msec))


func autosplitmerge_stress_test() -> void:
    var start_time_msec := Time.get_ticks_usec()
    const TEST_PROTOSET = preload("res://tests/data/protoset_grid.json")
    var inventory := create_inventory_grid(TEST_PROTOSET, Vector2i(20, 20))
    while true:
        var item_2x2 := create_item(TEST_PROTOSET, "item_2x2")
        item_2x2.set_max_stack_size(5)
        item_2x2.set_stack_size(randi_range(1, 4))
        if not inventory.add_item_autosplitmerge(item_2x2):
            break
    free_inventory(inventory)
    var end_time_msec := Time.get_ticks_usec()
    print("Autosplitmerge Stress Test: %dus" % (end_time_msec - start_time_msec))
