class_name InventoryComponent

signal inventory_set

var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        assert(new_inventory != null, "Can't set inventory to null!")
        assert(inventory == null, "Inventory already set!")
        inventory = new_inventory
        inventory_set.emit()


# Override this
func get_space_for(item: InventoryItem) -> ItemCount:
    return ItemCount.new(0)