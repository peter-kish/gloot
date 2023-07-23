@tool
extends Inventory
class_name InventoryGridStacked

signal size_changed

const DEFAULT_SIZE: Vector2i = Vector2i(10, 10)

@export var size: Vector2i = DEFAULT_SIZE :
    get:
        return _component_manager.get_grid_component().size
    set(new_size):
        _component_manager.get_grid_component().size = new_size


func _init() -> void:
    super._init()
    _component_manager.enable_grid_component_()
    _component_manager.enable_stacks_component_()
    _component_manager.get_grid_component().size_changed.connect(Callable(self, "_on_size_changed"))


func _on_size_changed() -> void:
    size_changed.emit()


func has_place_for(item: InventoryItem) -> bool:
    return _component_manager.has_space_for(item)


func add_item_automerge(item: InventoryItem) -> bool:
    return _component_manager.get_stacks_component().add_item_automerge(item)
    
    
func split(item: InventoryItem, new_stack_size: int) -> InventoryItem:
    return _component_manager.get_stacks_component().split_stack_safe(item, new_stack_size)


func join(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    return _component_manager.get_stacks_component().join_stacks(item_dst, item_src)


static func get_item_stack_size(item: InventoryItem) -> int:
    return StacksComponent.get_item_stack_size(item)


static func set_item_stack_size(item: InventoryItem, new_stack_size: int) -> void:
    StacksComponent.set_item_stack_size(item, new_stack_size)


static func get_item_max_stack_size(item: InventoryItem) -> int:
    return StacksComponent.get_item_max_stack_size(item)


static func set_item_max_stack_size(item: InventoryItem, new_stack_size: int) -> void:
    StacksComponent.set_item_max_stack_size(item, new_stack_size)


func get_prototype_stack_size(prototype_id: String) -> int:
    return _component_manager.get_stacks_component().get_prototype_stack_size(item_protoset, prototype_id)


func get_prototype_max_stack_size(prototype_id: String) -> int:
    return _component_manager.get_stacks_component().get_prototype_max_stack_size(item_protoset, prototype_id)


func transfer_automerge(item: InventoryItem, destination: Inventory) -> bool:
    return _component_manager.get_stacks_component().transfer_automerge(item, destination)


func transfer_autosplitmerge(item: InventoryItem, destination: Inventory) -> bool:
    return _component_manager.get_stacks_component().transfer_autosplitmerge(item, destination)


func transfer_to(item: InventoryItem, destination: Inventory, position: Vector2i) -> bool:
    return _component_manager.get_grid_component().transfer_to(item, destination._component_manager.get_grid_component(), position)
