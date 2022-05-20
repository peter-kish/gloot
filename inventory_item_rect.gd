extends InventoryItem
class_name InventoryItemRect


var rotated: bool = false;


func rotate() -> void:
    rotated = !rotated;
