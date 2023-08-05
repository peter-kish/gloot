var inventory: Inventory = null :
    get:
        return inventory
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
func _on_item_modified(item: InventoryItem) -> void:
    pass
