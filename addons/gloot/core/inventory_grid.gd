@tool
@icon("res://addons/gloot/images/icon_inventory_grid.svg")
extends Inventory
class_name InventoryGrid

## Inventory that has a limited capacity in terms of space.
##
## The inventory capacity is defined by its width and height.

## Emitted when the size of the inventory has changed.
signal size_changed

const DEFAULT_SIZE: Vector2i = Vector2i(10, 10)

## The size of the inventory (width and height).
@export var size: Vector2i = DEFAULT_SIZE :
    get:
        if _constraint_manager == null:
            return DEFAULT_SIZE
        if _constraint_manager.get_grid_constraint() == null:
            return DEFAULT_SIZE
        return _constraint_manager.get_grid_constraint().size
    set(new_size):
        _constraint_manager.get_grid_constraint().size = new_size


func _init() -> void:
    super._init()
    _constraint_manager.enable_grid_constraint()
    _constraint_manager.get_grid_constraint().size_changed.connect(func(): size_changed.emit())

## Returns the position of the given item in the inventory.
func get_item_position(item: InventoryItem) -> Vector2i:
    return _constraint_manager.get_grid_constraint().get_item_position(item)

## Returns the size of the given item.
func get_item_size(item: InventoryItem) -> Vector2i:
    return _constraint_manager.get_grid_constraint().get_item_size(item)

## Returns the position and size of the given item in the inventory.
func get_item_rect(item: InventoryItem) -> Rect2i:
    return _constraint_manager.get_grid_constraint().get_item_rect(item)

## Sets the item rotation (indicated by the [code]rotation[/code] property).
##
## Items can be rotated by positive or negative 90 degrees (indicated by the
## [code]positive_rotation[/code] property).
##
## Returns [code]false[/code] if the rotation can't be performed, i.e. the item
## is already rotated or the rotation is obstructed by other items/inventory
## boundaries.
func set_item_rotation(item: InventoryItem, rotated: bool) -> bool:
    return _constraint_manager.get_grid_constraint().set_item_rotation(item, rotated)

## Toggles item rotation. Returns [code]false[/code] if the rotation can't be
## performed, i.e. the item is already rotated or the rotation is obstructed
## by other items/inventory boundaries.
func rotate_item(item: InventoryItem) -> bool:
    return _constraint_manager.get_grid_constraint().rotate_item(item)

## Checks if the item is rotated (indicated by the [code]rotated[/code]
## property).
func is_item_rotated(item: InventoryItem) -> bool:
    return _constraint_manager.get_grid_constraint().is_item_rotated(item)

## Checks if there's place for the item to be rotated.
func can_rotate_item(item: InventoryItem) -> bool:
    return _constraint_manager.get_grid_constraint().can_rotate_item(item)

## Sets the item rotation to positive or negative (indicated by the
## [code]positive_rotation[/code] property).
## This does not affect the resulting size of the rotated item, only the
## way it is rendered in the UI. If the item seems to be rendered upside-down
## after a rotation, set the rotation direction to negative.
func set_item_rotation_direction(item: InventoryItem, positive: bool) -> void:
    _constraint_manager.set_item_rotation_direction(item, positive)

## Checks if the item rotation is positive (indicated by the
## [code]positive_rotation[/code]).
func is_item_rotation_positive(item: InventoryItem) -> bool:
    return _constraint_manager.get_grid_constraint().is_item_rotation_positive(item)

## Adds the given item to the inventory, at the given position.
func add_item_at(item: InventoryItem, position: Vector2i) -> bool:
    return _constraint_manager.get_grid_constraint().add_item_at(item, position)

## Creates an [InventoryItem] based on the given prototype ID and adds it
## to the inventory at the given position. Returns [code]null[/code] if the
## item cannot be added.
func create_and_add_item_at(prototype_id: String, position: Vector2i) -> InventoryItem:
    return _constraint_manager.get_grid_constraint().create_and_add_item_at(prototype_id, position)

## Returns the item at the given position in the inventory. Returns
## [code]null[/code] if the given field is empty.
func get_item_at(position: Vector2i) -> InventoryItem:
    return _constraint_manager.get_grid_constraint().get_item_at(position)


func get_items_under(rect: Rect2i) -> Array[InventoryItem]:
    return _constraint_manager.get_grid_constraint().get_items_under(rect)

## Moves the given item in the inventory to the new given position.
func move_item_to(item: InventoryItem, position: Vector2i) -> bool:
    return _constraint_manager.get_grid_constraint().move_item_to(item, position)

## Transfers the given item to the given inventory to the given inventory position.
func transfer_to(item: InventoryItem, destination: Inventory, position: Vector2i) -> bool:
    return _constraint_manager.get_grid_constraint().transfer_to(item, destination._constraint_manager.get_grid_constraint(), position)

## Checks if the given rectangle is not occupied by any items (with a given
## optional exception).
func rect_free(rect: Rect2i, exception: InventoryItem = null) -> bool:
    return _constraint_manager.get_grid_constraint().rect_free(rect, exception)

## Finds a free place for the given item. Returns a dictionary with two fields:
## [code]success[/code] and [code]position[/code]. If [code]success[/code] is
## true a free place has been found and is stored in the [code]position[/code]
## field. Otherwise [code]success[/code] is set to false.
func find_free_place(item: InventoryItem) -> Dictionary:
    return _constraint_manager.get_grid_constraint().find_free_place(item)

## Sorts the inventory items by size.
func sort() -> bool:
    return _constraint_manager.get_grid_constraint().sort()

