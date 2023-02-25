extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
    print("Running tests")
    for test_suite in get_children():
        if test_suite is TestSuite:
            test_suite.run()
    var orphan_count := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
    if orphan_count != 0:
        print("Stray nodes (%d):" % orphan_count)
        print_stray_nodes()
    assert(orphan_count == 0)
    print("All passed")
    get_tree().quit()
