@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_item.svg")
class_name CtrlInventoryItemBase
extends Control
## Base class for `CtrlInventoryItem`.
##
## `CtrlInventoryItemBase` defines some signals and members used for displaying an `InventoryItem`. Must be inherited
## when defining a custom class for representing inventory items.

## Emitted when the `item` property has been changed.
signal item_changed

## Emitted when the `icon_stretch_mode` property has been changed.
signal icon_stretch_mode_changed

## Reference to the `InventoryItem` that is being displayed.
var item: InventoryItem = null:
    set(new_item):
        if item == new_item:
            return
        item = new_item
        item_changed.emit()

@export_group("Icon Behavior", "icon_")
## Controls the item icon behavior when resizing the node's bounding rectangle. See the `TextureRect.StretchMode`
## constants for details.
@export var icon_stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_SCALE:
    set(new_icon_stretch_mode):
        if new_icon_stretch_mode == icon_stretch_mode:
            return
        icon_stretch_mode = new_icon_stretch_mode
        icon_stretch_mode_changed.emit()
