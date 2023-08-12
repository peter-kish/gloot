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


func add(item_count_: ItemCount) -> ItemCount:
    if item_count_.is_inf():
        count = Inf
    elif !self.is_inf():
        count += item_count_.count

    return self


func mul(item_count_: ItemCount) -> ItemCount:
    if (count == 0):
        return self
    if item_count_.is_inf():
        count = Inf
        return self
    if item_count_.count == 0:
        count = 0
        return self
    if self.is_inf():
        return self

    count *= item_count_.count
    return self


func div(item_count_: ItemCount) -> ItemCount:
    assert(item_count_.count > 0 || item_count_.is_inf(), "Can't devide by zero!")
    if (count == 0):
        return self
    if item_count_.is_inf() && self.is_inf():
        count = 1
        return self
    if self.is_inf():
        return self
    if item_count_.is_inf():
        count = 0
        return self

    count /= item_count_.count
    return self


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


func gt(item_count_: ItemCount) -> bool:
    if item_count_.is_inf():
        if self.is_inf():
            return false
        return false 

    if self.is_inf():
        return true

    return count > item_count_.count


static func min(item_count_l: ItemCount, item_count_r: ItemCount) -> ItemCount:
    if item_count_l.less(item_count_r):
        return item_count_l
    return item_count_r


static func inf() -> ItemCount:
    return ItemCount.new(Inf)


static func zero() -> ItemCount:
    return ItemCount.new(0)


# TODO: Implement le()
# TODO: Implement ge()
# TODO: Implement max()
