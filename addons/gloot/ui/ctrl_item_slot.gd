@tool
@icon("res://addons/gloot/images/icon_ctrl_item_slot.svg")
class_name CtrlItemSlot
extends Control
## A control node representing an inventory slot (`ItemSlot`).
##
## A control node representing an inventory slot (`ItemSlot`).


const CtrlDraggableInventoryItem = preload("res://addons/gloot/ui/ctrl_draggable_inventory_item.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")
const CtrlDraggable = preload("res://addons/gloot/ui/ctrl_draggable.gd")
const Utils = preload("res://addons/gloot/core/utils.gd")

## Reference to the item slot that is being displayed.
@export var item_slot: ItemSlot :
    set(new_item_slot):
        if new_item_slot == item_slot:
            return

        _disconnect_item_slot_signals()
        item_slot = new_item_slot
        _connect_item_slot_signals()
        
        _refresh()

@export_group("Icon Behavior", "icon_")
## Controls the item icon behavior when resizing the node's bounding rectangle. See the `TextureRect.StretchMode`
## constants for details.
@export var icon_stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_KEEP_CENTERED :
    set(new_icon_stretch_mode):
        if icon_stretch_mode == new_icon_stretch_mode:
            return
        icon_stretch_mode = new_icon_stretch_mode
        if is_instance_valid(_ctrl_draggable_inventory_item):
            _ctrl_draggable_inventory_item.stretch_mode = icon_stretch_mode

@export_group("Custom Styles")
## The slot background style.
@export var slot_style: StyleBox :
    set(new_slot_style):
        if slot_style == new_slot_style:
            return
        slot_style = new_slot_style
        _refresh()
## The slot background style when the mouse cursor hovers over the slot.
@export var slot_highlighted_style: StyleBox :
    set(new_slot_highlighted_style):
        if slot_highlighted_style == new_slot_highlighted_style:
            return
        slot_highlighted_style = new_slot_highlighted_style
        _refresh()

var _background_panel: Panel
var _ctrl_draggable_inventory_item: CtrlDraggableInventoryItem
var _ctrl_drop_zone: CtrlDropZone


func _connect_item_slot_signals() -> void:
    if !is_instance_valid(item_slot):
        return
    Utils.safe_connect(item_slot.item_equipped, _refresh)
    Utils.safe_connect(item_slot.cleared, _refresh)


func _disconnect_item_slot_signals() -> void:
    if !is_instance_valid(item_slot):
        return
    Utils.safe_disconnect(item_slot.item_equipped, _refresh)
    Utils.safe_disconnect(item_slot.cleared, _refresh)


func _ready():
    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        for c in get_children():
            remove_child(c)
            c.queue_free()

    _background_panel = Panel.new()
    _background_panel.size = size
    _set_panel_style(_background_panel, slot_style)
    add_child(_background_panel)

    _ctrl_draggable_inventory_item = CtrlDraggableInventoryItem.new()
    _ctrl_draggable_inventory_item.icon_stretch_mode = icon_stretch_mode
    _ctrl_draggable_inventory_item.size = size
    add_child(_ctrl_draggable_inventory_item)

    _ctrl_drop_zone = CtrlDropZone.new()
    _ctrl_drop_zone.draggable_dropped.connect(_on_draggable_dropped)
    _ctrl_drop_zone.size = size
    CtrlDraggable.draggable_grabbed.connect(_on_any_draggable_grabbed)
    CtrlDraggable.draggable_dropped.connect(_on_any_draggable_dropped)
    add_child(_ctrl_drop_zone)
    _ctrl_drop_zone.deactivate()

    resized.connect(func():
        if is_instance_valid(_background_panel):
            _background_panel.size = size
        if is_instance_valid(_ctrl_drop_zone):
            _ctrl_drop_zone.size = size
        if is_instance_valid(_ctrl_draggable_inventory_item):
            _ctrl_draggable_inventory_item.size = size
    )

    _refresh()


func _on_draggable_dropped(draggable: CtrlDraggable, drop_position: Vector2) -> void:
    var item = (draggable.metadata as CtrlDraggableInventoryItem).item

    if !item:
        return
    if !is_instance_valid(item_slot):
        return
        
    if !item_slot.can_hold_item(item):
        return

    if item == item_slot.get_item():
        return

    if _join_stacks(item_slot.get_item(), item):
        return

    if _swap_items(item_slot.get_item(), item):
        return
        
    if item_slot.get_item() == null:
        item_slot.equip(item)


func _join_stacks(item_dst: InventoryItem, item_src: InventoryItem) -> bool:
    if item_dst == null:
        return false
    if !is_instance_valid(item_dst.get_inventory()):
        return false
    return item_src.merge_into(item_dst)


func _swap_items(item1: InventoryItem, item2: InventoryItem) -> bool:
    if item_slot.get_item() == null:
        return false

    return InventoryItem.swap(item1, item2)


func _on_any_draggable_grabbed(draggable: CtrlDraggable, grab_position: Vector2):
    _ctrl_drop_zone.activate()


func _on_any_draggable_dropped(draggable: CtrlDraggable, zone: CtrlDropZone, drop_position: Vector2):
    _ctrl_drop_zone.deactivate()


func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_END:
        _ctrl_drop_zone.deactivate()


func _refresh() -> void:
    _clear()

    if !is_instance_valid(item_slot):
        return

    var item = item_slot.get_item()
    if !is_instance_valid(item):
        return
        
    if is_instance_valid(_ctrl_draggable_inventory_item):
        _ctrl_draggable_inventory_item.item = item


func _clear() -> void:
    if is_instance_valid(_ctrl_draggable_inventory_item):
        _ctrl_draggable_inventory_item.item = null


func _set_panel_style(panel: Panel, style: StyleBox) -> void:
    panel.remove_theme_stylebox_override("panel")
    if style != null:
        panel.add_theme_stylebox_override("panel", style)


func _input(event) -> void:
    if event is InputEventMouseMotion:
        if !is_instance_valid(_background_panel):
            return

        if get_global_rect().has_point(get_global_mouse_position()) && slot_highlighted_style:
            _set_panel_style(_background_panel, slot_highlighted_style)
            return
        
        if slot_style:
            _set_panel_style(_background_panel, slot_style)
        else:
            _background_panel.hide()
