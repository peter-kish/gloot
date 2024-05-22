@tool
@icon("res://addons/gloot/images/icon_ctrl_capacity.svg")
class_name  CtrlInventoryCapacity
extends Control

const Utils = preload("res://addons/gloot/core/utils.gd")
const StackManager = preload("res://addons/gloot/core/stack_manager.gd")

@export var show_label = true :
    set(new_show_label):
        if new_show_label == show_label:
            return
        show_label = new_show_label
        if _label != null:
            _label.visible = show_label

@export var inventory: Inventory = null :
    set(new_inventory):
        if inventory == new_inventory:
            return

        if inventory != null:
            _disconnect_inventory_signals()
        inventory = new_inventory
        if inventory != null:
            _connect_inventory_signals()
        _refresh()
        update_configuration_warnings()

var _progress_bar: ProgressBar
var _label: Label


func _get_configuration_warnings() -> PackedStringArray:
    if !is_instance_valid(inventory):
        return PackedStringArray([
                "This CtrlInventoryCapacity node has no inventory set. Set the 'inventory' field to be able to " \
                + "display its capacity."])
    if inventory.get_constraint(WeightConstraint) == null:
        return PackedStringArray([
                "The inventory has no WeightConstraint child node. Add a WeightConstraint to the inventory to be able" \
                + " to display its capacity."])
    return PackedStringArray()


func _connect_inventory_signals() -> void:
    if !inventory.is_node_ready():
        Utils.safe_connect(inventory.ready, _refresh)
    inventory.prototree_json_changed.connect(_refresh)
    inventory.constraint_changed.connect(_on_constraint_changed)
    inventory.constraint_added.connect(_on_constraint_changed)
    inventory.constraint_removed.connect(_on_constraint_changed)
    inventory.item_added.connect(_on_item_manipulated)
    inventory.item_removed.connect(_on_item_manipulated)
    inventory.item_property_changed.connect(_on_item_property_changed)


func _disconnect_inventory_signals() -> void:
    Utils.safe_disconnect(inventory.ready, _refresh)
    inventory.prototree_json_changed.disconnect(_refresh)
    inventory.constraint_changed.disconnect(_on_constraint_changed)
    inventory.constraint_added.disconnect(_on_constraint_changed)
    inventory.constraint_removed.disconnect(_on_constraint_changed)
    inventory.item_added.disconnect(_on_item_manipulated)
    inventory.item_removed.disconnect(_on_item_manipulated)
    inventory.item_property_changed.disconnect(_on_item_property_changed)


func _on_constraint_changed(constraint: InventoryConstraint) -> void:
    if constraint is WeightConstraint:
        _refresh()


func _on_item_manipulated(item: InventoryItem) -> void:
    _refresh()


func _on_item_property_changed(item: InventoryItem, property: String) -> void:
    if property == StackManager.KEY_STACK_SIZE || property == WeightConstraint.KEY_WEIGHT:
        _refresh()


func _refresh() -> void:
    if !is_instance_valid(_label) || !is_instance_valid(_progress_bar):
        return

    _label.text = ""
    _progress_bar.min_value = 0
    _progress_bar.max_value = 1
    if inventory == null || !inventory.is_node_ready():
        return

    var weight_constraint := inventory.get_constraint(WeightConstraint)
    if weight_constraint == null:
        return

    _progress_bar.max_value = weight_constraint.capacity
    _label.text = "%s/%s" % [str(weight_constraint.get_occupied_space()), str(weight_constraint.capacity)]
    _progress_bar.value = weight_constraint.get_occupied_space()


func _ready() -> void:
    _progress_bar = ProgressBar.new()
    _progress_bar.show_percentage = false
    add_child(_progress_bar)

    _label = Label.new()
    _label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _label.visible = show_label
    add_child(_label)

    custom_minimum_size.y = _label.size.y
    size.y = _label.size.y
    _label.size.x = size.x
    _progress_bar.size = size
    _label.resized.connect(func():
        custom_minimum_size.y = _label.size.y
        size.y = _label.size.y
    )
    resized.connect(func():
        _progress_bar.size = size
        _label.size.x = size.x
    )

    _refresh()
