extends InventoryItemStackable
class_name InventoryItemWeight


export(float) var unit_weight = 1.0 setget _set_unit_weight;


func get_weight() -> float:
    return stack_size * unit_weight;


func _set_unit_weight(new_unit_weight: float) -> void:
    assert(new_unit_weight >= 0.0, "Unit weight must be greater or equal to 0!");
    unit_weight = new_unit_weight;
    emit_signal("weight_changed", get_weight());
