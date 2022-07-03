extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
    print("Running tests")
    for test_suite in get_children():
        if test_suite is TestSuite:
            test_suite.run()
    print("All passed")
    get_tree().quit()
