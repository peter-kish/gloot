@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_item.svg")
class_name CtrlInventoryItemBase
extends Control

signal item_changed
signal pre_item_changed
signal icon_stretch_mode_changed

var item: InventoryItem = null :
    set(new_item):
        if item == new_item:
            return
        pre_item_changed.emit()
        item = new_item
        item_changed.emit()

@export_group("Icon Behavior", "icon_")
@export var icon_stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_SCALE :
    set(new_icon_stretch_mode):
        if new_icon_stretch_mode == icon_stretch_mode:
            return
        icon_stretch_mode = new_icon_stretch_mode
        icon_stretch_mode_changed.emit()