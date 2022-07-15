extends Control
tool


onready var prototype_id_filter = $HBoxContainer/ChoiceFilter
onready var inventory_control_container = $HBoxContainer/VBoxContainer
var inventory: Inventory setget _set_inventory
var _inventory_control: Control


func _set_inventory(new_inventory: Inventory) -> void:
    if inventory:
        if inventory is InventoryStacked:
            inventory.disconnect("capacity_changed", self, "refresh")
        inventory.disconnect("protoset_changed", self, "_on_inventory_protoset_changed")

    inventory = new_inventory
    
    if inventory:
        if inventory is InventoryStacked:
            inventory.connect("capacity_changed", self, "refresh")
        inventory.connect("protoset_changed", self, "_on_inventory_protoset_changed")

    _refresh()


func _refresh() -> void:
    if !is_inside_tree() || inventory == null || inventory.item_protoset == null:
        return
        
    # Remove the inventory control, if present
    if _inventory_control:
        inventory_control_container.remove_child(_inventory_control)
        _inventory_control.free()
        _inventory_control = null

    # Create the appropriate inventory control and populate it
    if inventory is InventoryGrid:
        _inventory_control = CtrlInventoryGrid.new()
        _inventory_control.grid_color = Color.gray
    elif inventory is InventoryStacked:
        _inventory_control = CtrlInventoryStacked.new()
    elif inventory is Inventory:
        _inventory_control = CtrlInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory
    inventory_control_container.add_child(_inventory_control)
    inventory_control_container.move_child(_inventory_control, 0)

    # Set prototype_id_filter values
    prototype_id_filter.values = inventory.item_protoset._prototypes.keys()


func _ready() -> void:
    prototype_id_filter.connect("choice_picked", self, "_on_prototype_id_picked")
    _refresh()


func _on_prototype_id_picked(index: int) -> void:
    var item = InventoryItem.new()
    item.protoset = inventory.item_protoset
    item.prototype_id = prototype_id_filter.values[index]
    item.name = item.prototype_id
    inventory.add_item(item)
    