@tool
extends Inventory
class_name InventoryGrid

signal size_changed

const DEFAULT_SIZE: Vector2i = Vector2i(10, 10)

@export var size: Vector2i = DEFAULT_SIZE :
    get:
        return _component_manager.get_grid_component().size
    set(new_size):
        _component_manager.get_grid_component().size = new_size


func _init() -> void:
    super._init()
    _component_manager.enable_grid_component()
    _component_manager.get_grid_component().size_changed.connect(Callable(self, "_on_size_changed"))


func _on_size_changed() -> void:
    size_changed.emit()


func get_item_position(item: InventoryItem) -> Vector2i:
    return _component_manager.get_grid_component().get_item_position(item)


func get_item_size(item: InventoryItem) -> Vector2i:
    return _component_manager.get_grid_component().get_item_size(item)


func get_item_rect(item: InventoryItem) -> Rect2i:
    return _component_manager.get_grid_component().get_item_rect(item)


func add_item_at(item: InventoryItem, position: Vector2i) -> bool:
    return _component_manager.get_grid_component().add_item_at(item, position)


func create_and_add_item_at(prototype_id: String, position: Vector2i) -> InventoryItem:
    return _component_manager.get_grid_component().create_and_add_item_at(prototype_id, position)


func get_item_at(position: Vector2i) -> InventoryItem:
    return _component_manager.get_grid_component().get_item_at(position)


func get_items_under(rect: Rect2i) -> Array[InventoryItem]:
    return _component_manager.get_grid_component().get_items_under(rect)


func move_item_to(item: InventoryItem, position: Vector2i) -> bool:
    return _component_manager.get_grid_component().move_item_to(item, position)


func transfer_to(item: InventoryItem, destination: Inventory, position: Vector2i) -> bool:
    return _component_manager.get_grid_component().transfer_to(item, destination._component_manager.get_grid_component(), position)


func rect_free(rect: Rect2i, exception: InventoryItem = null) -> bool:
    return _component_manager.get_grid_component().rect_free(rect, exception)


func find_free_place(item: InventoryItem) -> Dictionary:
    return _component_manager.get_grid_component().find_free_place(item)


func sort() -> bool:
    return _component_manager.get_grid_component().sort()

