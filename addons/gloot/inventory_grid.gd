extends Inventory
class_name InventoryGrid
tool

signal size_changed

const KEY_WIDTH: String = "width"
const KEY_HEIGHT: String = "height"
const KEY_SIZE: String = "size"
const KEY_ITEM_POSITIONS: String = "item_positions"
const DEFAULT_SIZE: Vector2 = Vector2(10, 10)

export(Vector2) var size: Vector2 = DEFAULT_SIZE setget _set_size

var _item_positions: Array = []


class Space:
    var capacity: Vector2
    var reserved_rects: Array


    func _init(capacity_: Vector2):
        capacity = capacity_.round()


    func reserve(size: Vector2) -> bool:
        var free_rect = _find_free_space(size.round())
        if GlootVerify.rect_positive(free_rect):
            reserved_rects.append(free_rect)
            return true
        return false


    func _find_free_space(size: Vector2) -> Rect2:
        size = size.round()
        for x in range(int(capacity.x) - (int(size.x) - 1)):
            for y in range(int(capacity.y) - (int(size.y) - 1)):
                var space: Rect2 = Rect2(Vector2(x, y), size)
                if _rect_free(space):
                    return space
        return Rect2(-1, -1, -1, -1)


    func _rect_free(rect: Rect2) -> bool:
        if rect.position.x + rect.size.x > capacity.x:
            return false
        if rect.position.y + rect.size.y > capacity.y:
            return false
    
        for item_rect in reserved_rects:
            if rect.intersects(item_rect):
                return false
    
        return true


func _get_configuration_warning() -> String:
    if _is_full_by_default():
        return "Inventory capacity exceeded!"
    return ""


func _is_full_by_default() -> bool:
    var space: Space = Space.new(size)
    for prototype_id in contents:
        var prototype_size = _get_prototype_size(prototype_id)
        if !space.reserve(prototype_size):
            return true
    return false


func _get_prototype_size(prototype_id: String) -> Vector2:
    if item_protoset:
        var width: int = item_protoset.get_item_property(prototype_id, KEY_WIDTH, 1)
        var height: int = item_protoset.get_item_property(prototype_id, KEY_HEIGHT, 1)
        return Vector2(width, height)
    return Vector2(1, 1)


func get_item_position(item: InventoryItem) -> Vector2:
    return _item_positions[_get_item_index(item)]


func _get_item_index(item: InventoryItem) -> int:
    var item_index: int = get_items().find(item)
    assert(item_index >= 0, "The inventory does not contain this item!")
    return item_index


func get_item_size(item: InventoryItem) -> Vector2:
    var item_width: int = item.get_property(KEY_WIDTH, 1)
    var item_height: int = item.get_property(KEY_HEIGHT, 1)
    if item.get_property("rotated", false):
        var temp = item_width
        item_width = item_height
        item_height = temp
    return Vector2(item_width, item_height)


func get_item_rect(item: InventoryItem) -> Rect2:
    var item_pos: Vector2 = get_item_position(item)
    var item_size: Vector2 = get_item_size(item)
    return Rect2(item_pos, item_size)
    

func _ready():
    assert(size.x > 0, "Inventory width must be positive!")
    assert(size.y > 0, "Inventory height must be positive!")


func _set_size(new_size: Vector2) -> void:
    new_size = new_size.round()
    assert(new_size.x > 0, "Inventory width must be positive!")
    assert(new_size.y > 0, "Inventory height must be positive!")
    var old_size = size
    size = new_size
    update_configuration_warning()
    if !Engine.editor_hint:
        if _bounds_broken():
            size = old_size
    if size != old_size:
        emit_signal("size_changed")


func _bounds_broken() -> bool:
    for item in get_items():
        if !rect_free(get_item_rect(item), item):
            return true

    return false


func _set_contents(new_contents: Array) -> void:
    ._set_contents(new_contents)
    update_configuration_warning()


func _populate() -> void:
    contents.sort_custom(self, "_compare_prototypes")
    ._populate()


func _compare_prototypes(prototype_id_1: String, prototype_id_2: String) -> bool:
    var size_1 = _get_prototype_size(prototype_id_1)
    var size_2 = _get_prototype_size(prototype_id_2)
    # Compare areas
    return (size_1.x * size_1.y) > (size_2.x * size_2.y)


func add_item(item: InventoryItem) -> bool:
    var free_place = find_free_place(item)
    if !GlootVerify.vector_positive(free_place):
        return false

    return add_item_at(item, free_place)


func add_item_at(item: InventoryItem, position: Vector2) -> bool:
    var item_size = get_item_size(item)
    var rect: Rect2 = Rect2(position, item_size)
    if rect_free(rect):
        _item_positions.append(position)
        if .add_item(item):
            return true
        else:
            _item_positions.pop_back()
            return false

    return false


func remove_item(item: InventoryItem) -> bool:
    var item_index = _get_item_index(item)
    _item_positions.remove(item_index)
    return .remove_item(item)


func move_item(item: InventoryItem, position: Vector2) -> bool:
    var item_size = get_item_size(item)
    var rect: Rect2 = Rect2(position, item_size)
    if rect_free(rect, item):
        _item_positions[_get_item_index(item)] = position
        emit_signal("contents_changed")
        return true

    return false


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    return transfer_to(item, destination, Vector2.ZERO)


func transfer_to(item: InventoryItem, destination: InventoryGrid, position: Vector2) -> bool:
    var item_size = get_item_size(item)
    var rect: Rect2 = Rect2(position, item_size)
    if destination.rect_free(rect):
        if .transfer(item, destination):
            destination.move_item(item, position)
            return true

    return false


func rect_free(rect: Rect2, exception: InventoryItem = null) -> bool:
    if rect.position.x + rect.size.x > size.x:
        return false
    if rect.position.y + rect.size.y > size.y:
        return false

    for item in get_items():
        if item == exception:
            continue
        var item_pos: Vector2 = get_item_position(item)
        var item_size: Vector2 = get_item_size(item)
        var rect2: Rect2 = Rect2(item_pos, item_size)
        if rect.intersects(rect2):
            return false

    return true


func find_free_place(item: InventoryItem) -> Vector2:
    var item_size = get_item_size(item)
    for x in range(size.x - (item_size.x - 1)):
        for y in range(size.y - (item_size.y - 1)):
            var rect: Rect2 = Rect2(Vector2(x, y), item_size)
            if rect_free(rect, item):
                return Vector2(x, y)

    return Vector2(-1, -1)


func _compare_items(item1: InventoryItem, item2: InventoryItem) -> bool:
    var rect1: Rect2 = Rect2(get_item_position(item1), get_item_size(item1))
    var rect2: Rect2 = Rect2(get_item_position(item2), get_item_size(item2))
    return rect1.get_area() > rect2.get_area()


func sort() -> bool:
    var item_array: Array
    for item in get_items():
        item_array.append(item)
    item_array.sort_custom(self, "_compare_items")

    for item in get_items():
        remove_item(item)

    for item in item_array:
        var free_place: Vector2 = find_free_place(item)
        if !GlootVerify.vector_positive(free_place):
            return false
        add_item_at(item, free_place)

    return true


func reset() -> void:
    .reset()
    _item_positions = []
    size = DEFAULT_SIZE


func clear() -> void:
    .clear()
    _item_positions = []


func serialize() -> Dictionary:
    var result: Dictionary = .serialize()

    result[KEY_SIZE] = size
    if !_item_positions.empty():
        result[KEY_ITEM_POSITIONS] = _item_positions

    return result


func deserialize(source: Dictionary) -> bool:
    if !GlootVerify.dict(source, true, KEY_SIZE, TYPE_VECTOR2) ||\
        !GlootVerify.dict(source, false, KEY_ITEM_POSITIONS, TYPE_ARRAY, TYPE_VECTOR2):
        return false

    reset()

    if !.deserialize(source):
        return false

    size = source[KEY_SIZE]
    if source.has(KEY_ITEM_POSITIONS):
        var positions = source[KEY_ITEM_POSITIONS]
        for position in positions:
            _item_positions.append(position)

    return true
