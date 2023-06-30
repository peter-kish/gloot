class_name ItemCount

const Inf: int = -1

@export var count: int = 0 :
    get:
        return count
    set(new_count):
        if new_count < 0:
            new_count = -1
        count = new_count


func _init(count_: int = 0) -> void:
    if count_ < 0:
        count_ = -1
    count = count_


func is_inf() -> bool:
    return count < 0


func expand(item_count_: ItemCount) -> void:
    if item_count_.is_inf():
        count = Inf
    elif !self.is_inf():
        count += item_count_.count


func eq(item_count_: ItemCount) -> bool:
    return item_count_.count == count


func less(item_count_: ItemCount) -> bool:
    if item_count_.is_inf():
        if self.is_inf():
            return false
        return true 

    if self.is_inf():
        return false

    return count < item_count_.count
    
