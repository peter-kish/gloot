@tool
@icon("res://addons/gloot/images/icon_grid_constraint.svg")
extends InventoryConstraint
class_name GridConstraint
## A constraint that limits the inventory to a 2d grid of a given size.
##
## The constraint implements a grid-based inventory of a configurable size.

const _Verify = preload("res://addons/gloot/core/verify.gd")
const _QuadTree = preload("res://addons/gloot/core/constraints/quadtree.gd")
const _Utils = preload("res://addons/gloot/core/utils.gd")

## Default size of the 2d grid.
const DEFAULT_SIZE: Vector2i = Vector2i(10, 10)

const _KEY_SIZE: String = "size"
const _KEY_ROTATED: String = "rotated"
const _KEY_POSITIVE_ROTATION: String = "positive_rotation"
const _KEY_ITEM_POSITIONS: String = "item_positions"
const _KEY_INSERTION_PRIORITY: String = "insertion_priority"

enum {INSERTION_PRIORITY_HORIZONTAL = 0, INSERTION_PRIORITY_VERTICAL = 1}

var _swap_positions: Array[Vector2i]
var _item_positions := {}
var _quad_tree := _QuadTree.new(size)
var _inventory_set_stack: Array[Callable]

## The size of the 2d grid.
@export var size: Vector2i = DEFAULT_SIZE:
    set(new_size):
        assert(new_size.x > 0, "Inventory width must be positive!")
        assert(new_size.y > 0, "Inventory height must be positive!")
        var old_size = size
        size = new_size
        if !Engine.is_editor_hint():
            if _bounds_broken():
                size = old_size
        if size != old_size:
            _refresh_quad_tree()
            changed.emit()
## Insertion priority. Defines whether items will be stacked horizontally-first or vertically-first when inserted into
## the 2d grid.
@export_enum("Horizontal", "Vertical") var insertion_priority: int = INSERTION_PRIORITY_VERTICAL:
    set(new_insertion_priority):
        if new_insertion_priority == insertion_priority:
            return
        insertion_priority = new_insertion_priority
        changed.emit()


func _push_inventory_set_operation(c: Callable) -> void:
    _inventory_set_stack.push_back(c)


func _refresh_quad_tree() -> void:
    _quad_tree = _QuadTree.new(size)
    if !is_instance_valid(inventory):
        return
    for item in inventory.get_items():
        _quad_tree.add(get_item_rect(item), item)


func _on_inventory_set() -> void:
    _item_positions.clear()
    while !_inventory_set_stack.is_empty():
        _inventory_set_stack.pop_back().call()
    _refresh_quad_tree()


func _on_item_added(item: InventoryItem) -> void:
    if item == null:
        return
    if move_item_to_free_spot(item):
        _quad_tree.add(get_item_rect(item), item)
    else:
        inventory.pack_item(item)


func _on_item_removed(item: InventoryItem) -> void:
    _quad_tree.remove(item)
    _item_positions.erase(item)

    
func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    if property == _KEY_SIZE:
        _refresh_quad_tree()


func _on_pre_item_swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    var inv1 = item1.get_inventory()
    var inv2 = item2.get_inventory()
    var grid_constraint1: GridConstraint = null
    var grid_constraint2: GridConstraint = null
    var pos1 = Vector2i.ZERO
    var pos2 = Vector2i.ZERO
    if is_instance_valid(inv1):
        grid_constraint1 = inv1.get_constraint(GridConstraint)
        if is_instance_valid(grid_constraint1):
            pos1 = grid_constraint1.get_item_position(item1)
    if is_instance_valid(inv2):
        grid_constraint2 = inv2.get_constraint(GridConstraint)
        if is_instance_valid(grid_constraint2):
            pos2 = grid_constraint2.get_item_position(item2)
    
    _swap_positions = [pos1, pos2]
    if is_instance_valid(grid_constraint1) || is_instance_valid(grid_constraint2):
        return get_item_size(item1) == get_item_size(item2)
    return true


func _on_post_item_swap(item1: InventoryItem, item2: InventoryItem) -> void:
    const ITEM1_IDX = 0
    const ITEM2_IDX = 1
    if is_instance_valid(item1.get_inventory()) && is_instance_valid(item1.get_inventory().get_constraint(GridConstraint)):
        item1.get_inventory().get_constraint(GridConstraint).set_item_position_unsafe(item1, _swap_positions[ITEM2_IDX])
    if is_instance_valid(item2.get_inventory()) && is_instance_valid(item2.get_inventory().get_constraint(GridConstraint)):
        item2.get_inventory().get_constraint(GridConstraint).set_item_position_unsafe(item2, _swap_positions[ITEM1_IDX])


func _bounds_broken() -> bool:
    if !is_instance_valid(inventory):
        return false
    for item in inventory.get_items():
        if !rect_free(get_item_rect(item), item):
            return true

    return false


## Returns the position of the given item on the 2d grid.
func get_item_position(item: InventoryItem) -> Vector2i:
    if !_item_positions.has(item):
        return Vector2i.ZERO
    return _item_positions[item]


## Sets the position of the given item on the 2d grid.
func set_item_position(item: InventoryItem, new_position: Vector2i) -> bool:
    var new_rect := Rect2i(new_position, get_item_size(item))
    if inventory.has_item(item) and !rect_free(new_rect, item):
        return false

    set_item_position_unsafe(item, new_position)
    return true


## Sets the position of the given item on the 2d grid without any validity checks (somewhat faster than
## set_item_position).
func set_item_position_unsafe(item: InventoryItem, new_position: Vector2i) -> void:
    if new_position == get_item_position(item):
        return

    _item_positions[item] = new_position
    _refresh_quad_tree()
    changed.emit()


## Returns the size of the given item (i.e. the `size` property).
func get_item_size(item: InventoryItem) -> Vector2i:
    var result: Vector2i = item.get_property(_KEY_SIZE, Vector2i.ONE)
    if is_item_rotated(item):
        var temp := result.x
        result.x = result.y
        result.y = temp
    return result


## Checks wether the given item is rotated (i.e. whether the `rotated` property is set).
static func is_item_rotated(item: InventoryItem) -> bool:
    return item.get_property(_KEY_ROTATED, false)


## Checks wether the given item has positive rotation.
static func is_item_rotation_positive(item: InventoryItem) -> bool:
    return item.get_property(_KEY_POSITIVE_ROTATION, false)


# TODO: Consider making a static "unsafe" version of this
## Sets the size of the given item (i.e. the `size` property).
func set_item_size(item: InventoryItem, new_size: Vector2i) -> bool:
    if new_size.x < 1 || new_size.y < 1:
        return false

    var new_rect := Rect2i(get_item_position(item), new_size)
    if inventory.has_item(item) and !rect_free(new_rect, item):
        return false

    item.set_property(_KEY_SIZE, new_size)
    return true


## Sets the rotation of the given item (i.e. the `rotated` property).
func set_item_rotation(item: InventoryItem, rotated: bool) -> bool:
    if is_item_rotated(item) == rotated:
        return false
    if !can_rotate_item(item):
        return false

    if rotated:
        item.set_property(_KEY_ROTATED, true)
    else:
        item.clear_property(_KEY_ROTATED)

    return true


## Rotates the given item (i.e. toggles the `rotated` property).
func rotate_item(item: InventoryItem) -> bool:
    return set_item_rotation(item, !is_item_rotated(item))


## Sets the rotation direction of the given item (positive or negative, i.e. sets the `positive_rotation` property).
static func set_item_rotation_direction(item: InventoryItem, positive: bool) -> void:
    if positive:
        item.set_property(_KEY_POSITIVE_ROTATION, true)
    else:
        item.clear_property(_KEY_POSITIVE_ROTATION)


## Checks if the given item can be rotated.
func can_rotate_item(item: InventoryItem) -> bool:
    var rotated_rect := get_item_rect(item)
    var temp := rotated_rect.size.x
    rotated_rect.size.x = rotated_rect.size.y
    rotated_rect.size.y = temp
    return rect_free(rotated_rect, item)


## Returns a rectangle constructed from the position and size of the given item.
func get_item_rect(item: InventoryItem) -> Rect2i:
    var item_pos := get_item_position(item)
    var item_size := get_item_size(item)
    return Rect2i(item_pos, item_size)


## Sets the position and size of the given item based on the given rectangle. Returns `false` if the new position and
## size cannot be applied to the item.
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
    assert(inventory.protoset != null, "Inventory protoset is null!")
    var size: Vector2i = inventory.get_prototree().get_prototype_property(prototype_id, _KEY_SIZE, Vector2i.ONE)
    return size


## Adds the given item to the inventory and sets its position.
func add_item_at(item: InventoryItem, position: Vector2i) -> bool:
    assert(inventory != null, "Inventory not set!")

    var item_size := get_item_size(item)
    var rect := Rect2i(position, item_size)
    if rect_free(rect):
        if not inventory.add_item(item):
            return false
        var success = move_item_to(item, position)
        assert(success, "Can't move the item to the given place!")
        return true

    return false


## Creates and adds the given item to the inventory and sets its position.
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


## Returns the item at the given grid position. Returns `null` if no item can be found at that position.
func get_item_at(position: Vector2i) -> InventoryItem:
    assert(inventory != null, "Inventory not set!")
    var first = _quad_tree.get_first(position)
    if first == null:
        return null
    return first.metadata


## Returns an array of items under the given rectangle.
func get_items_under(rect: Rect2i) -> Array[InventoryItem]:
    assert(inventory != null, "Inventory not set!")
    var result: Array[InventoryItem]
    for item in inventory.get_items():
        var item_rect := get_item_rect(item)
        if item_rect.intersects(rect):
            result.append(item)
    return result


## Moves the given item to a new position. Returns `false` if the item cannot be moved.
func move_item_to(item: InventoryItem, position: Vector2i) -> bool:
    assert(inventory != null, "Inventory not set!")
    var item_size := get_item_size(item)
    var rect := Rect2i(position, item_size)
    if rect_free(rect, item):
        set_item_position_unsafe(item, position)
        changed.emit()
        return true

    return false


## Moves the given item to a free spot. Returns `false` if no free spot can be found.
func move_item_to_free_spot(item: InventoryItem) -> bool:
    if rect_free(get_item_rect(item), item):
        return true

    var free_place := find_free_place(item, item)
    if not free_place.success:
        return false

    return move_item_to(item, free_place.position)


func _merge_to(item: InventoryItem, destination: GridConstraint, position: Vector2i) -> bool:
    var item_dst := destination._get_mergable_item_at(item, position)
    if item_dst == null:
        return false

    return item.merge_into(item_dst)
    

func _get_mergable_item_at(item: InventoryItem, position: Vector2i) -> InventoryItem:
    var rect := Rect2i(position, get_item_size(item))
    var mergable_items := _get_mergable_items_under(item, rect)
    for mergable_item in mergable_items:
        if item.can_merge_into(mergable_item):
            return mergable_item
    return null


func _get_mergable_items_under(item: InventoryItem, rect: Rect2i) -> Array[InventoryItem]:
    var result: Array[InventoryItem]

    for item_dst in get_items_under(rect):
        if item_dst == item:
            continue
        if item.can_merge_into(item_dst):
            result.append(item_dst)

    return result


## Checks if the given rectangle is free (i.e. no items can be found under it). The `exception` item will be disregarded
## during the check, if set.
func rect_free(rect: Rect2i, exception: InventoryItem = null) -> bool:
    assert(inventory != null, "Inventory not set!")

    if rect.position.x < 0 || rect.position.y < 0 || rect.size.x < 1 || rect.size.y < 1:
        return false
    if rect.position.x + rect.size.x > size.x:
        return false
    if rect.position.y + rect.size.y > size.y:
        return false

    return _quad_tree.get_first(rect, exception) == null


# TODO: Check if this is needed after adding find_free_space
## Finds a place for the given item. The `exception` item will be disregarded during the search, if set. Returns a
## dictionary containing two fields: `success` and `position`. `success` will be set to `false` if not free place can be
## found and to `true` otherwise. If `success` is true the `position` field contains the resulting coordinates. 
func find_free_place(item: InventoryItem, exception: InventoryItem = null) -> Dictionary:
    var result := {success = false, position = Vector2i(-1, -1)}
    var item_size = get_item_size(item)

    var check_position := func(pos: Vector2i) -> bool:
        var rect := Rect2i(pos, item_size)
        if rect_free(rect, exception):
            result.success = true
            result.position = pos
            return true
        return false

    if insertion_priority == INSERTION_PRIORITY_VERTICAL:
        for x in range(size.x - (item_size.x - 1)):
            for y in range(size.y - (item_size.y - 1)):
                if check_position.call(Vector2i(x, y)):
                    return result
    else:
        for y in range(size.y - (item_size.y - 1)):
            for x in range(size.x - (item_size.x - 1)):
                if check_position.call(Vector2i(x, y)):
                    return result

    return result


func _compare_items(item1: InventoryItem, item2: InventoryItem) -> bool:
    var rect1 := Rect2i(get_item_position(item1), get_item_size(item1))
    var rect2 := Rect2i(get_item_position(item2), get_item_size(item2))
    return rect1.get_area() > rect2.get_area()


## Sorts the inventory based on item size.
func sort() -> bool:
    assert(inventory != null, "Inventory not set!")

    var item_array: Array[InventoryItem]
    for item in inventory.get_items():
        item_array.append(item)
    item_array.sort_custom(_compare_items)

    for item in item_array:
        set_item_position_unsafe(item, -get_item_size(item))

    for item in item_array:
        var free_place := find_free_place(item)
        if !free_place.success:
            return false
        move_item_to(item, free_place.position)

    return true


## Returns the number of times this constraint can receive the given item.
func get_space_for(item: InventoryItem) -> int:
    var result = _get_free_space_for(item) * item.get_max_stack_size()

    for i in inventory.get_items():
        if item.can_merge_into(i, true):
            result += i.get_free_stack_space()

    return result


func _get_free_space_for(item: InventoryItem) -> int:
    var item_size = get_item_size(item)
    var occupied_rects: Array[Rect2i]
    var free_space := find_free_space(item_size, occupied_rects)

    while free_space.success:
        occupied_rects.append(Rect2i(free_space.position, item_size))
        free_space = find_free_space(item_size, occupied_rects)
    return occupied_rects.size()
    

## Checks if the constraint can receive the given item. 
func has_space_for(item: InventoryItem) -> bool:
    var item_size = get_item_size(item)

    if find_free_space(item_size).success:
        return true

    var total_free_stack_space = 0
    for i in inventory.get_items():
        if item.compatible_with(i):
            total_free_stack_space += i.get_free_stack_space()
    return total_free_stack_space >= item.get_stack_size()


# TODO: Check if find_free_place is needed
## Finds a place for the given item with regard to the given occupied rectangles. Returns a dictionary containing two
## fields: `success` and `position`. `success` will be set to `false` if not free place can be found and to `true`
## otherwise. If `success` is true the `position` field contains the resulting coordinates. 
func find_free_space(item_size: Vector2i, occupied_rects: Array[Rect2i] = []) -> Dictionary:
    var result := {success = false, position = Vector2i(-1, -1)}
    for x in range(size.x - (item_size.x - 1)):
        for y in range(size.y - (item_size.y - 1)):
            var rect := Rect2i(Vector2i(x, y), item_size)
            if rect_free(rect) and not _rect_intersects_rect_array(rect, occupied_rects):
                result.success = true
                result.position = Vector2i(x, y)
                return result

    return result


static func _rect_intersects_rect_array(rect: Rect2i, occupied_rects: Array[Rect2i] = []) -> bool:
    for occupied_rect in occupied_rects:
        if rect.intersects(occupied_rect):
            return true
    return false


## Resets the constraint, i.e. sets its size to default (`Vector2i(10, 10)`).
func reset() -> void:
    size = DEFAULT_SIZE
    _quad_tree = _QuadTree.new(size)
    _item_positions.clear()
    insertion_priority = INSERTION_PRIORITY_VERTICAL


## Serializes the constraint into a `Dictionary`.
func serialize() -> Dictionary:
    var result := {}

    # Store Vector2i as string to make JSON conversion easier later
    result[_KEY_SIZE] = var_to_str(size)
    result[_KEY_ITEM_POSITIONS] = _serialize_item_positions()
    if insertion_priority == INSERTION_PRIORITY_HORIZONTAL:
        result[_KEY_INSERTION_PRIORITY] = int(insertion_priority)

    return result


func _serialize_item_positions() -> Dictionary:
    var result = {}
    for item in _item_positions.keys():
        var str_item_index := var_to_str(inventory.get_item_index(item))
        var str_item_position = var_to_str(_item_positions[item])
        result[str_item_index] = str_item_position
    return result


## Loads the constraint data from the given `Dictionary`.
func deserialize(source: Dictionary) -> bool:
    if !_Verify.dict(source, true, _KEY_SIZE, TYPE_STRING) || \
        !_Verify.dict(source, false, _KEY_INSERTION_PRIORITY, [TYPE_INT, TYPE_FLOAT]):
        return false

    reset()

    # Queue this part of the deserialization for later if the inventory is still not set
    if is_instance_valid(inventory):
        _deserialize_item_positions(source[_KEY_ITEM_POSITIONS])
    else:
        _push_inventory_set_operation(_deserialize_item_positions.bind(source[_KEY_ITEM_POSITIONS].duplicate()))

    size = _Utils.str_to_var(source[_KEY_SIZE])
    if source.has(_KEY_INSERTION_PRIORITY):
        insertion_priority = int(source[_KEY_INSERTION_PRIORITY])

    return true


func _deserialize_item_positions(source: Dictionary) -> bool:
    for str_item_index in source.keys():
        var item_index: int = _Utils.str_to_var(str_item_index)
        var item := inventory.get_items()[item_index]
        var item_position = _Utils.str_to_var(source[str_item_index])
        set_item_position_unsafe(item, item_position)
    return true
