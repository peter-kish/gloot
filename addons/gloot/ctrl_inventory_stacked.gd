class_name CtrlInventoryStacked
extends CtrlInventory
tool

export(bool) var progress_bar_visible = true setget _set_progress_bar_visible
export(bool) var percent_visible = true setget _set_percent_visible
var _progress_bar: ProgressBar


func _set_progress_bar_visible(new_progress_bar_visible: bool) -> void:
    progress_bar_visible = new_progress_bar_visible
    if _progress_bar:
        _progress_bar.visible = progress_bar_visible


func _set_percent_visible(new_percent_visible: bool) -> void:
    percent_visible = new_percent_visible
    if _progress_bar:
        _progress_bar.percent_visible = percent_visible


func _ready():
    _progress_bar = ProgressBar.new()
    _progress_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    _progress_bar.percent_visible = percent_visible
    _progress_bar.visible = progress_bar_visible
    add_child(_progress_bar)


func _connect_signals() -> void:
    inventory.connect("capacity_changed", self, "_refresh")
    inventory.connect("occupied_space_changed", self, "_refresh")


func _disconnect_signals() -> void:
    inventory.disconnect("capacity_changed", self, "_refresh")
    inventory.disconnect("occupied_space_changed", self, "_refresh")


func _refresh():
    ._refresh()
    if _progress_bar:
        _progress_bar.percent_visible = percent_visible
        _progress_bar.visible = progress_bar_visible
        _progress_bar.min_value = 0
        _progress_bar.max_value = inventory.capacity
        _progress_bar.value = inventory.occupied_space

