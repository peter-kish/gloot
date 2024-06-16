@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_stacked.svg")
class_name CtrlInventoryStacked
extends CtrlInventory

## A UI control representing a stack based inventory ([InventoryStacked]).
##
## It lists the contained items and shows an optional progress bar displaying
## the capacity and fullness of the inventory.

## If true, a progress bar will be shown indicating inventory fullness.
@export var progress_bar_visible: bool = true :
    set(new_progress_bar_visible):
        progress_bar_visible = new_progress_bar_visible
        if _progress_bar:
            _progress_bar.visible = progress_bar_visible

## If true, a percentage label will be shown indicating inventory fullness.
@export var label_visible: bool = true :
    set(new_label_visible):
        label_visible = new_label_visible
        if _label:
            _label.visible = label_visible
var _progress_bar: ProgressBar
var _label: Label


func _ready():
    super._ready()
    
    _progress_bar = ProgressBar.new()
    _progress_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    _progress_bar.show_percentage = false
    _progress_bar.visible = progress_bar_visible
    _progress_bar.custom_minimum_size.y = 20
    _vbox_container.add_child(_progress_bar)

    _label = Label.new()
    _label.anchor_right = 1.0
    _label.anchor_bottom = 1.0
    _label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _progress_bar.add_child(_label)

    _queue_refresh()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    super._connect_inventory_signals()

    if !inventory.capacity_changed.is_connected(_queue_refresh):
        inventory.capacity_changed.connect(_queue_refresh)
    if !inventory.occupied_space_changed.is_connected(_queue_refresh):
        inventory.occupied_space_changed.connect(_queue_refresh)


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    super._disconnect_inventory_signals()

    if !inventory.capacity_changed.is_connected(_queue_refresh):
        inventory.capacity_changed.disconnect(_queue_refresh)
    if !inventory.occupied_space_changed.is_connected(_queue_refresh):
        inventory.occupied_space_changed.disconnect(_queue_refresh)


func _refresh():
    super._refresh()
    if is_instance_valid(_label):
        _label.visible = label_visible
        _label.text = "%d/%d" % [inventory.occupied_space, inventory.capacity]
    if is_instance_valid(_progress_bar):
        _progress_bar.visible = progress_bar_visible
        _progress_bar.min_value = 0
        _progress_bar.max_value = inventory.capacity
        _progress_bar.value = inventory.occupied_space

