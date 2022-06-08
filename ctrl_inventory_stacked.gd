class_name CtrlInventoryStacked
extends CtrlInventory
tool

export(bool) var progress_bar_visible = true setget _set_progress_bar_visible;
export(bool) var percent_visible = true setget _set_percent_visible;
var progress_bar: ProgressBar;


func _set_progress_bar_visible(new_progress_bar_visible: bool) -> void:
    progress_bar_visible = new_progress_bar_visible
    if progress_bar:
        progress_bar.visible = progress_bar_visible;


func _set_percent_visible(new_percent_visible: bool) -> void:
    percent_visible = new_percent_visible;
    if progress_bar:
        progress_bar.percent_visible = percent_visible;


func _ready():
    progress_bar = ProgressBar.new();
    progress_bar.size_flags_horizontal = SIZE_EXPAND_FILL;
    progress_bar.percent_visible = percent_visible;
    progress_bar.visible = progress_bar_visible;
    add_child(progress_bar);


func _connect_signals() -> void:
    inventory.connect("capacity_changed", self, "_refresh");
    inventory.connect("occupied_space_changed", self, "_refresh");


func _disconnect_signals() -> void:
    inventory.disconnect("capacity_changed", self, "_refresh");
    inventory.disconnect("occupied_space_changed", self, "_refresh");


func _refresh():
    ._refresh();
    if progress_bar:
        var inventory_stacked: InventoryStacked = inventory;
        progress_bar.percent_visible = percent_visible;
        progress_bar.visible = progress_bar_visible;
        progress_bar.min_value = 0;
        progress_bar.max_value = inventory_stacked.capacity;
        progress_bar.value = inventory_stacked.occupied_space;

