extends Node
class_name InventoryConstraint

signal changed

var inventory: Inventory = null :
    set(new_inventory):
        inventory = new_inventory
        if is_instance_valid(inventory):
            _on_inventory_set()


func _notification(what: int) -> void:
    if what == NOTIFICATION_PARENTED:
        _on_parented(get_parent())
    elif what == NOTIFICATION_UNPARENTED:
        _on_unparented()


func _on_parented(parent: Node) -> void:
    if parent is Inventory:
        inventory = parent
        inventory._on_constraint_added(self)
    else:
        inventory = null


func _on_unparented() -> void:
    if inventory == null:
        return
    inventory._on_constraint_removed(self)
    inventory = null


# Override this
func get_space_for(item: InventoryItem) -> ItemCount:
    return ItemCount.zero()


# Override this
func has_space_for(item:InventoryItem) -> bool:
    return false


# Override this
func reset() -> void:
    pass


# Override this
func serialize() -> Dictionary:
    return {}


# Override this
func deserialize(source: Dictionary) -> bool:
    return true
    
    
# Override this
func _on_inventory_set() -> void:
    pass


# Override this
func _on_item_added(item: InventoryItem) -> void:
    pass


# Override this
func _on_item_removed(item: InventoryItem) -> void:
    pass


# Override this
func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    pass


# Override this
func _on_pre_item_swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    return true


# Override this
func _on_post_item_swap(item1: InventoryItem, item2: InventoryItem) -> void:
    pass


# Override this
func enforce(item: InventoryItem) -> void:
    pass
    
