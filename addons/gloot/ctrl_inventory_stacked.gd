@tool
class_name CtrlInventoryStacked
extends CtrlInventory

@export var progress_bar_visible: bool = true :
    get:
        return progress_bar_visible
    set(new_progress_bar_visible):
        progress_bar_visible = new_progress_bar_visible
        if _progress_bar:
            _progress_bar.visible = progress_bar_visible
@export var label_visible: bool = true :
    get:
        return label_visible
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

    _refresh()


func _connect_inventory_signals() -> void:
    if !inventory:
        return

    super._connect_inventory_signals()

    if !inventory.capacity_changed.is_connected(Callable(self, "_refresh")):
        inventory.capacity_changed.connect(Callable(self, "_refresh"))
    if !inventory.occupied_space_changed.is_connected(Callable(self, "_refresh")):
        inventory.occupied_space_changed.connect(Callable(self, "_refresh"))


func _disconnect_inventory_signals() -> void:
    if !inventory:
        return

    super._disconnect_inventory_signals()

    if !inventory.capacity_changed.is_connected(Callable(self, "_refresh")):
        inventory.capacity_changed.disconnect(Callable(self, "_refresh"))
    if !inventory.occupied_space_changed.is_connected(Callable(self, "_refresh")):
        inventory.occupied_space_changed.disconnect(Callable(self, "_refresh"))


func _refresh():
    super._refresh()
    if _label:
        _label.visible = label_visible
        _label.text = "%d/%d" % [inventory.occupied_space, inventory.capacity]
    if _progress_bar:
        _progress_bar.visible = progress_bar_visible
        _progress_bar.min_value = 0
        _progress_bar.max_value = inventory.capacity
        _progress_bar.value = inventory.occupied_space

