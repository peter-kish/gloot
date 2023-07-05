class_name GridComponent
extends InventoryComponent

signal size_changed

const Verify = preload("res://addons/gloot/verify.gd")

# TODO: Replace KEY_WIDTH and KEY_HEIGHT with KEY_SIZE
const KEY_WIDTH: String = "width"
const KEY_HEIGHT: String = "height"
const KEY_SIZE: String = "size"
const KEY_GRID_POSITION: String = "grid_position"
const DEFAULT_SIZE: Vector2i = Vector2i(10, 10)

@export var size: Vector2i = DEFAULT_SIZE :
    get:
        return size
    set(new_size):
        assert(new_size.x > 0, "Inventory width must be positive!")
        assert(new_size.y > 0, "Inventory height must be positive!")
        var old_size = size
        size = new_size
        if !Engine.is_editor_hint():
            if _bounds_broken():
                size = old_size
        if size != old_size:
            size_changed.emit()


func _bounds_broken() -> bool:
    for item in inventory.get_items():
        if !rect_free(get_item_rect(item), item):
            return true

    return false


func get_item_position(item: InventoryItem) -> Vector2i:
    return item.get_property(KEY_GRID_POSITION, Vector2i.ZERO)


func set_item_position(item: InventoryItem, new_position: Vector2i) -> bool:
    var new_rect := Rect2i(new_position, get_item_size(item))
    var inv_rect := Rect2i(Vector2i.ZERO, size)
    if !rect_free(new_rect, item):
        return false

    item.set_property(KEY_GRID_POSITION, new_position)
    return true


func get_item_size(item: InventoryItem) -> Vector2i:
    var item_width: int = item.get_property(KEY_WIDTH, 1)
    var item_height: int = item.get_property(KEY_HEIGHT, 1)
    if item.get_property("rotated", false):
        var temp = item_width
        item_width = item_height
        item_height = temp
    return Vector2i(item_width, item_height)


func set_item_size(item: InventoryItem, new_size: Vector2i) -> bool:
    if new_size.x < 1 || new_size.y < 1:
        return false

    var new_rect := Rect2i(get_item_position(item), new_size)
    if !rect_free(new_rect, item):
        return false

    item.set_property(KEY_WIDTH, new_size.x)
    item.set_property(KEY_HEIGHT, new_size.y)
    return true


func get_item_rect(item: InventoryItem) -> Rect2i:
    var item_pos := get_item_position(item)
    var item_size := get_item_size(item)
    return Rect2i(item_pos, item_size)


func set_item_rect(item: InventoryItem, new_rect: Rect2i) -> bool:
    if !rect_free(new_rect, item):
        return false
    if !set_item_position(item, new_rect.position):
        return false
    if !set_item_size(item, new_rect.size):
        return false
    return true


func _get_prototype_size(prototype_id: String) -> Vector2i:
    assert(inventory != null, "Inventory not set!")
    assert(inventory.item_protoset != null, "Inventory protoset is null!")
    var width: int = inventory.item_protoset.get_item_property(prototype_id, KEY_WIDTH, 1)
    var height: int = inventory.item_protoset.get_item_property(prototype_id, KEY_WIDTH, 1)
    return Vector2i(width, height)


func _is_sorted() -> bool:
    assert(inventory != null, "Inventory not set!")
    for item1 in inventory.get_items():
        for item2 in inventory.get_items():
            if item1 == item2:
                continue

            var rect1: Rect2i = get_item_rect(item1)
            var rect2: Rect2i = get_item_rect(item2)
            if rect1.intersects(rect2):
                return false;

    return true


func add_item_at(item: InventoryItem, position: Vector2i) -> bool:
    assert(inventory != null, "Inventory not set!")

    var item_size := get_item_size(item)
    var rect := Rect2i(position, item_size)
    if rect_free(rect):
        item.properties[KEY_GRID_POSITION] = position
        if item.properties[KEY_GRID_POSITION] == Vector2i.ZERO:
            item.properties.erase(KEY_GRID_POSITION)
        return inventory.add_item(item)

    return false


func create_and_add_item_at(prototype_id: String, position: Vector2i) -> InventoryItem:
    assert(inventory != null, "Inventory not set!")
    var item_rect := Rect2i(position, _get_prototype_size(prototype_id))
    if !rect_free(item_rect):
        return null

    var item = inventory.create_and_add_item(prototype_id)
    if item == null:
        return null

    if not move_item_to(item, position):
        inventory.remove_item(item)
        return null

    return item


func get_item_at(position: Vector2i) -> InventoryItem:
    assert(inventory != null, "Inventory not set!")
    for item in inventory.get_items():
        if get_item_rect(item).has_point(position):
            return item
    return null


func get_items_under(rect: Rect2i) -> Array[InventoryItem]:
    assert(inventory != null, "Inventory not set!")
    var result: Array[InventoryItem]
    for item in inventory.get_items():
        var item_rect := get_item_rect(item)
        if item_rect.intersects(rect):
            result.append(item)
    return result


func move_item_to(item: InventoryItem, position: Vector2i) -> bool:
    assert(inventory != null, "Inventory not set!")
    var item_size := get_item_size(item)
    var rect := Rect2i(position, item_size)
    if rect_free(rect, item):
        _move_item_to_unsafe(item, position)
        inventory.contents_changed.emit()
        return true

    return false


func _move_item_to_unsafe(item: InventoryItem, position: Vector2i) -> void:
    item.properties[KEY_GRID_POSITION] = position
    if item.properties[KEY_GRID_POSITION] == Vector2i.ZERO:
        item.properties.erase(KEY_GRID_POSITION)


func transfer_to(item: InventoryItem, destination: GridComponent, position: Vector2i) -> bool:
    assert(inventory != null, "Inventory not set!")
    assert(destination.inventory != null, "Destination inventory not set!")
    var item_size = get_item_size(item)
    var rect := Rect2i(position, item_size)
    if destination.rect_free(rect):
        if inventory.transfer(item, destination.inventory):
            destination.move_item_to(item, position)
            return true

    return false


func rect_free(rect: Rect2i, exception: InventoryItem = null) -> bool:
    assert(inventory != null, "Inventory not set!")

    if rect.position.x < 0 || rect.position.y < 0 || rect.size.x < 1 || rect.size.y < 1:
        return false
    if rect.position.x + rect.size.x > size.x:
        return false
    if rect.position.y + rect.size.y > size.y:
        return false

    for item in inventory.get_items():
        if item == exception:
            continue
        var item_pos := get_item_position(item)
        var item_size := get_item_size(item)
        var rect2 := Rect2i(item_pos, item_size)
        if rect.intersects(rect2):
            return false

    return true


# TODO: Check if this is needed after adding find_free_space
func find_free_place(item: InventoryItem) -> Vector2i:
    var item_size = get_item_size(item)
    for x in range(size.x - (item_size.x - 1)):
        for y in range(size.y - (item_size.y - 1)):
            var rect := Rect2i(Vector2i(x, y), item_size)
            if rect_free(rect):
                return Vector2i(x, y)

    return Vector2i(-1, -1)


func _compare_items(item1: InventoryItem, item2: InventoryItem) -> bool:
    var rect1 := Rect2i(get_item_position(item1), get_item_size(item1))
    var rect2 := Rect2i(get_item_position(item2), get_item_size(item2))
    return rect1.get_area() > rect2.get_area()


func sort() -> bool:
    assert(inventory != null, "Inventory not set!")

    var item_array: Array[InventoryItem]
    for item in inventory.get_items():
        item_array.append(item)
    item_array.sort_custom(Callable(self, "_compare_items"))

    for item in item_array:
        _move_item_to_unsafe(item, -get_item_size(item))

    for item in item_array:
        var free_place := find_free_place(item)
        if !Verify.vector_positive(free_place):
            return false
        move_item_to(item, free_place)

    return true


func _sort_if_needed() -> void:
    if !_is_sorted() || _bounds_broken():
        sort()


func get_space_for(item: InventoryItem) -> ItemCount:
    var occupied_rects: Array[Rect2i]
    var item_size = item.get_size()
    var free_space = find_free_space(item_size, occupied_rects)
    while free_space.ok():
        occupied_rects.append(free_space.get())
        free_space = find_free_space(size, occupied_rects)
    return ItemCount.new(occupied_rects.size())


# TODO: Check if find_free_place is needed
func find_free_space(item_size: Vector2i, occupied_rects: Array[Rect2i] = []) -> Vector2i:
    for x in range(size.x - (item_size.x - 1)):
        for y in range(size.y - (item_size.y - 1)):
            var rect := Rect2i(Vector2i(x, y), item_size)
            if rect_free(rect) and not _rect_intersects_rect_array(rect, occupied_rects):
                return Vector2i(x, y)

    return Vector2i(-1, -1)


static func _rect_intersects_rect_array(rect: Rect2i, occupied_rects: Array[Rect2i] = []) -> bool:
    for occupied_rect in occupied_rects:
        if rect.intersects(occupied_rect):
            return true
    return false