class_name ItemCount

const Inf: int = -1

@export var space: int = 0 :
    get:
        return space
    set(new_space):
        if new_space < 0:
            new_space = -1
        space = new_space


func _init(space_: int = 0) -> void:
    if space_ < 0:
        space_ = -1
    space = space_


func is_inf() -> bool:
    return space < 0


func expand(inventory_space_: ItemCount) -> void:
    if inventory_space_.is_inf():
        space = Inf
    elif !self.is_inf():
        space += inventory_space_.space


func eq(inventory_space_: ItemCount) -> bool:
    return inventory_space_.space == space


func less(inventory_space_: ItemCount) -> bool:
    if inventory_space_.is_inf():
        if self.is_inf():
            return false
        return true 

    if self.is_inf():
        return false

    return space < inventory_space_.space
    
