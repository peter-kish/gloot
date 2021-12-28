extends InventoryItemStackable
class_name InventoryItemWeight


export(float) var weight = 1.0 setget _set_weight;


func get_weight() -> float:
    return stack_size * weight;


func _set_weight(new_weight: float) -> void:
    assert(new_weight >= 0.0, "Weight must be greater or equal to 0!");
    weight = new_weight;
    emit_signal("weight_changed", get_weight());
