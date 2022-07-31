class_name CtrlInventoryStacked
extends CtrlInventory
tool

export(bool) var progress_bar_visible = true setget _set_progress_bar_visible
export(bool) var label_visible = true setget _set_label_visible
var _progress_bar: ProgressBar
var _label: Label


func _set_progress_bar_visible(new_progress_bar_visible: bool) -> void:
    progress_bar_visible = new_progress_bar_visible
    if _progress_bar:
        _progress_bar.visible = progress_bar_visible


func _set_label_visible(new_label_visible: bool) -> void:
    label_visible = new_label_visible
    if _label:
        _label.visible = label_visible


func _ready():
    _progress_bar = ProgressBar.new()
    _progress_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    _progress_bar.percent_visible = false
    _progress_bar.visible = progress_bar_visible
    _progress_bar.rect_min_size.y = 20
    _vbox_container.add_child(_progress_bar)

    _label = Label.new()
    _label.anchor_right = 1.0
    _label.anchor_bottom = 1.0
    _label.align = Label.ALIGN_CENTER
    _label.valign = Label.VALIGN_CENTER
    _progress_bar.add_child(_label)

    _refresh()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    ._connect_inventory_signals()

    if !inventory.is_connected("capacity_changed", self, "_refresh"):
        inventory.connect("capacity_changed", self, "_refresh")
    if !inventory.is_connected("occupied_space_changed", self, "_refresh"):
        inventory.connect("occupied_space_changed", self, "_refresh")


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    ._disconnect_inventory_signals()

    if !inventory.is_connected("capacity_changed", self, "_refresh"):
        inventory.disconnect("capacity_changed", self, "_refresh")
    if !inventory.is_connected("occupied_space_changed", self, "_refresh"):
        inventory.disconnect("occupied_space_changed", self, "_refresh")


func _refresh():
    ._refresh()
    if _label:
        _label.visible = label_visible
        _label.text = "%d/%d" % [inventory.occupied_space, inventory.capacity]
    if _progress_bar:
        _progress_bar.visible = progress_bar_visible
        _progress_bar.min_value = 0
        _progress_bar.max_value = inventory.capacity
        _progress_bar.value = inventory.occupied_space

