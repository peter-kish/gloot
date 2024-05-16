@tool
class_name  CtrlInventoryUniversal
extends VBoxContainer

# TODO: Consider renaming to item_activated
signal inventory_item_activated(item)
signal inventory_item_context_activated(item)

@export var inventory: Inventory = null :
    set(new_inventory):
        if inventory == new_inventory:
            return
        disconnect_inventory_signals()
        inventory = new_inventory
        connect_inventory_signals()
        _refresh()

var _inventory_control: Control = null
var _capacity_control: CtrlInventoryCapacity = null


func connect_inventory_signals():
    if !inventory:
        return

    inventory.capacity_changed.connect(_refresh)
    inventory.size_changed.connect(_refresh)
    inventory.prototree_json_changed.connect(_refresh)
    inventory.constraint_enabled.connect(_on_constraint_toggled)
    inventory.constraint_disabled.connect(_on_constraint_toggled)

    if !inventory.prototree_json:
        return
    inventory.prototree_json.changed.connect(_refresh)


func disconnect_inventory_signals():
    if !inventory:
        return
        
    inventory.capacity_changed.disconnect(_refresh)
    inventory.size_changed.disconnect(_refresh)
    inventory.prototree_json_changed.disconnect(_refresh)
    inventory.constraint_enabled.disconnect(_on_constraint_toggled)
    inventory.constraint_disabled.disconnect(_on_constraint_toggled)

    if !inventory.prototree_json:
        return
    inventory.prototree_json.changed.disconnect(_refresh)


func _on_constraint_toggled(constraint: int) -> void:
    _refresh()


func _ready() -> void:
    _refresh()


func _refresh() -> void:
    if is_instance_valid(_inventory_control):
        _inventory_control.queue_free()
        _inventory_control = null
    if is_instance_valid(_capacity_control):
        _capacity_control.queue_free()
        _capacity_control = null

    if !is_instance_valid(inventory):
        return

    if inventory.get_grid_constraint() != null:
        _inventory_control = CtrlInventoryGridEx.new()
        _inventory_control.field_style = preload("res://addons/gloot/ui/default_grid_field.tres")
        _inventory_control.selection_style = preload("res://addons/gloot/ui/default_grid_selection.tres")
    else:
        _inventory_control = CtrlInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory
    _inventory_control.inventory_item_activated.connect(func(item: InventoryItem):
        inventory_item_activated.emit(item)
    )
    _inventory_control.inventory_item_context_activated.connect(func(item: InventoryItem):
        inventory_item_context_activated.emit(item)
    )
    if inventory.get_weight_constraint() != null:
        _capacity_control = CtrlInventoryCapacity.new()
        _capacity_control.inventory = inventory

    if is_instance_valid(_inventory_control):
        add_child(_inventory_control)
    if is_instance_valid(_capacity_control):
        add_child(_capacity_control)


func get_selected_inventory_item() -> InventoryItem:
    assert(is_instance_valid(_inventory_control))
    return _inventory_control.get_selected_inventory_item()


func get_selected_inventory_items() -> Array[InventoryItem]:
    assert(is_instance_valid(_inventory_control))
    return _inventory_control.get_selected_inventory_items()
