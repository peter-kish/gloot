extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
    print("Running tests")
    for test_suite in get_children():
        if test_suite is TestSuite:
            test_suite.run()


func _process(_delta: float) -> void:
    test_orphan_nodes()
    print("All passed")
    get_tree().quit()


func test_orphan_nodes() -> void:
    var orphan_count := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
    if orphan_count != 0:
        print("Orphan nodes (%d):" % orphan_count)
        Node.print_orphan_nodes()
    assert(orphan_count == 0)
