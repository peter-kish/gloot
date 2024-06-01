extends Object

var inventory: Inventory = null :
    set(new_inventory):
        assert(new_inventory != null, "Can't set inventory to null!")
        assert(inventory == null, "Inventory already set!")
        inventory = new_inventory
        _on_inventory_set()


func _init(inventory_: Inventory) -> void:
    inventory = inventory_


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
func _on_item_property_changed(item: InventoryItem, property_name: String) -> void:
    pass


# Override this
func _on_pre_item_swap(item1: InventoryItem, item2: InventoryItem) -> bool:
    return true


# Override this
func _on_post_item_swap(item1: InventoryItem, item2: InventoryItem) -> void:
    pass
