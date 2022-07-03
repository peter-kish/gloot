extends Node
class_name TestSuite

export(bool) var enabled = true
var tests: Array


func run():
    if enabled:
        init_suite()
        _run_tests()


# Called before the tests suite is run
func init_suite() -> void:
    pass


# Called before a unit test is run
func init_test() -> void:
    pass


# Runs the test suite
func _run_tests():
    for test in tests:
        init_test()
        if has_method(test):
            print("Running %s:%s" % [name, test])
            call(test)
        else:
            print("Warning: Test %s:%s not found!" % [name, test])
