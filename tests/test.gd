extends Node
class_name Test

export(bool) var enabled = true
var tests: Array


# Called when the node enters the scene tree for the first time.
func _ready():
    if enabled:
        setup()
        _run_tests()


func setup() -> void:
    pass


func reset() -> void:
    pass


func _run_tests():
    for test in tests:
        reset()
        print("Running %s:%s" % [name, test])
        if has_method(test):
            call(test)
        else:
            print("Warning: Test %s:%s not found!" % [name, test])
