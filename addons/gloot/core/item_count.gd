const _ItemCount = preload("res://addons/gloot/core/item_count.gd")

const Inf: int = -1

## The item count as an integer (-1 equals infinity).
@export var count: int = 0:
    set(new_count):
        if new_count < 0:
            new_count = -1
        count = new_count


func _init(count_: int = 0) -> void:
    if count_ < 0:
        count_ = -1
    count = count_


## Checks if the count is infinite.
func is_inf() -> bool:
    return count < 0


## Adds the given _ItemCount to the current one and returns the result.
func add(item_count_: _ItemCount) -> _ItemCount:
    if item_count_.is_inf():
        count = Inf
    elif !self.is_inf():
        count += item_count_.count

    return self


## Subtracts the given _ItemCount from the current one and returns the result.
func sub(item_count_: _ItemCount) -> _ItemCount:
    assert(!item_count_.gt(self), "Can't subtract a count greater than self!")
    if item_count_.is_inf():
        count = 0
    elif !self.is_inf():
        count -= item_count_.count

    return self


## Multiplies the given _ItemCount with the current one and returns the result.
func mul(item_count_: _ItemCount) -> _ItemCount:
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


## Divides the current _ItemCount with the given one and returns the result.
func div(item_count_: _ItemCount) -> _ItemCount:
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


## Check if the item count is equal with the given item count.
func eq(item_count_: _ItemCount) -> bool:
    return item_count_.count == count


## Check if the item count is less than the given item count.
func lt(item_count_: _ItemCount) -> bool:
    if item_count_.is_inf():
        if self.is_inf():
            return false
        return true

    if self.is_inf():
        return false

    return count < item_count_.count


## Check if the item count is less or equal than the given item count.
func le(item_count_: _ItemCount) -> bool:
    return self.lt(item_count_) || self.eq(item_count_)


## Check if the item count is greater than the given item count.
func gt(item_count_: _ItemCount) -> bool:
    if item_count_.is_inf():
        if self.is_inf():
            return false
        return false

    if self.is_inf():
        return true

    return count > item_count_.count


## Check if the item count is greater or equal than the given item count.
func ge(item_count_: _ItemCount) -> bool:
    return self.gt(item_count_) || self.eq(item_count_)


## Returns the smaller item count out of the two.
static func min(item_count_l: _ItemCount, item_count_r: _ItemCount) -> _ItemCount:
    if item_count_l.lt(item_count_r):
        return item_count_l
    return item_count_r


## Returns an infinite item count.
static func inf() -> _ItemCount:
    return _ItemCount.new(Inf)


## Returns an item count if 0.
static func zero() -> _ItemCount:
    return _ItemCount.new(0)


## Returns an item count if 1.
static func one() -> _ItemCount:
    return _ItemCount.new(1)


func _to_string() -> String:
    if self.is_inf():
        return "INF"
    return str(count)


# TODO: Implement max()
