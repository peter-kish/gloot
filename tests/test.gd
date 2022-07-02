extends Node
class_name Test


export(bool) var enabled = true
var tests: Array


# Called when the node enters the scene tree for the first time.
func _ready():
    if enabled:
        run_tests()


func reset() -> void:
    pass


func run_tests():
    for test in tests:
        reset()
        print("Running %s:%s" % [name, test])
        call(test)
