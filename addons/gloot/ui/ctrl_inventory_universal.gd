@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory.svg")
extends VBoxContainer

signal inventory_item_activated(item: InventoryItem)
signal inventory_item_clicked(item: InventoryItem)
signal inventory_item_selected(item: InventoryItem)

@export var inventory: Inventory = null:
    set(new_inventory):
        if inventory == new_inventory:
            return
        disconnect_inventory_signals()
        inventory = new_inventory
        connect_inventory_signals()
        _refresh()
        update_configuration_warnings()

var _inventory_control: Control = null
var _capacity_control: CtrlInventoryCapacity = null


func _get_configuration_warnings() -> PackedStringArray:
    if !is_instance_valid(inventory):
        return PackedStringArray([
                "This CtrlInventoryUniversal node has no inventory set. Set the 'inventory' field to be able to " \
                + "display its contents."])
    return PackedStringArray()


func connect_inventory_signals():
    if !inventory:
        return

    inventory.protoset_changed.connect(_refresh)
    inventory.constraint_changed.connect(_on_constraint_changed)
    inventory.constraint_added.connect(_on_constraint_changed)
    inventory.constraint_removed.connect(_on_constraint_changed)

    if !inventory.protoset:
        return
    inventory.protoset.changed.connect(_refresh)


func disconnect_inventory_signals():
    if !inventory:
        return
        
    inventory.protoset_changed.disconnect(_refresh)
    inventory.constraint_changed.disconnect(_on_constraint_changed)
    inventory.constraint_added.disconnect(_on_constraint_changed)
    inventory.constraint_removed.disconnect(_on_constraint_changed)

    if !inventory.protoset:
        return
    inventory.protoset.changed.disconnect(_refresh)


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
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

    if inventory.get_constraint(GridConstraint) != null:
        _inventory_control = CtrlInventoryGrid.new()
    else:
        _inventory_control = CtrlInventory.new()
    _inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
    _inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
    _inventory_control.inventory = inventory
    _inventory_control.inventory_item_activated.connect(func(item: InventoryItem):
        inventory_item_activated.emit(item)
    )
    _inventory_control.inventory_item_clicked.connect(func(item: InventoryItem, at_position: Vector2, mouse_button_index: int):
        inventory_item_clicked.emit(item, at_position, mouse_button_index)
    )
    _inventory_control.inventory_item_selected.connect(func(item: InventoryItem):
        inventory_item_selected.emit(item)
    )
    if inventory.get_constraint(WeightConstraint) != null:
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
