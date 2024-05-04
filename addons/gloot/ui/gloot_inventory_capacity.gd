@tool
class_name  GlootInventoryCapacity
extends Control

const Utils = preload("res://addons/gloot/core/utils.gd")

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

var _progress_bar: ProgressBar
var _label: Label


func _connect_inventory_signals() -> void:
    if !inventory.is_node_ready():
        Utils.safe_connect(inventory.ready, _refresh)
    inventory.contents_changed.connect(_refresh)
    inventory.prototree_json_changed.connect(_refresh)
    if inventory.get_weight_constraint():
        inventory.get_weight_constraint().capacity_changed.connect(_refresh)
        inventory.get_weight_constraint().occupied_space_changed.connect(_refresh)


func _disconnect_inventory_signals() -> void:
    Utils.safe_disconnect(inventory.ready, _refresh)
    inventory.contents_changed.disconnect(_refresh)
    inventory.prototree_json_changed.disconnect(_refresh)
    if inventory.get_weight_constraint():
        inventory.get_weight_constraint().capacity_changed.disconnect(_refresh)
        inventory.get_weight_constraint().occupied_space_changed.disconnect(_refresh)


func _refresh() -> void:
    if !is_instance_valid(_label) || !is_instance_valid(_progress_bar):
        return

    _label.text = ""
    _progress_bar.min_value = 0
    _progress_bar.max_value = 1
    if inventory == null || !inventory.is_node_ready():
        return

    var weight_constraint := inventory.get_weight_constraint()
    if weight_constraint == null:
        return

    _progress_bar.max_value = weight_constraint.capacity

    if weight_constraint.has_unlimited_capacity():
        _label.text = "%s/INF" % str(weight_constraint.occupied_space)
        _progress_bar.value = 0
    else:
        _label.text = "%s/%s" % [str(weight_constraint.occupied_space), str(weight_constraint.capacity)]
        _progress_bar.value = weight_constraint.occupied_space


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
