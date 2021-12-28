extends InventoryItem
class_name InventoryItemRect

signal rotated;
signal moved;


var x: int = 0;
var y: int = 0;
export(int) var width: int = 1;
export(int) var height: int = 1;
var rotated: bool = false;


func _ready():
    assert(x >= 0, "x must be positive!");
    assert(y >= 0, "y must be positive!");


func rotate() -> void:
    var temp: int = width;
    width = height;
    height = width;
    rotated = !rotated;
    emit_signal("rotated");


func move(new_x, new_y) -> void:
    assert(new_x >= 0, "x coordinate must be greater or equal to 0");
    assert(new_y >= 0, "y coordinate must be greater or equal to 0");
    x = new_x;
    y = new_y;
    emit_signal("moved");