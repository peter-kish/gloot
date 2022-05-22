extends Node
class_name Test


export(bool) var enabled = true;


# Called when the node enters the scene tree for the first time.
func _ready():
    if enabled:
        print("Running %s" % name);
        run_tests();


func run_tests():
    pass;
