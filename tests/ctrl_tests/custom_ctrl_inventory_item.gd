@tool
extends CtrlInventoryItemBase


func _ready():
    # Make sure the child CtrlInventoryItem node is synced with this one
    item_changed.connect(func(): %CtrlInventoryItem.item = item)
    icon_stretch_mode_changed.connect(func(): %CtrlInventoryItem.icon_stretch_mode = icon_stretch_mode)

    %ColorRect.size = size
    %CtrlInventoryItem.size = size
    %CtrlInventoryItem.item = item
    %CtrlInventoryItem.icon_stretch_mode = icon_stretch_mode


func _physics_process(_delta) -> void:
    if !is_instance_valid(item):
        %ColorRect.color = Color.TRANSPARENT
        return
    %ColorRect.color = item.get_property("background_color", Color.TRANSPARENT)
