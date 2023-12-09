@tool
class_name CtrlItemSlot
extends Control

const CtrlInventoryRect = preload("res://addons/gloot/ui/ctrl_inventory_item_rect.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")
const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")

@export var item_slot_path: NodePath :
    get:
        return item_slot_path
    set(new_item_slot_path):
        if item_slot_path == new_item_slot_path:
            return
        item_slot_path = new_item_slot_path
        var node: Node = get_node_or_null(item_slot_path)
        
        if node == null:
            _clear()
            return

        if is_inside_tree():
            assert(node is ItemSlot)
            
        item_slot = node
        _refresh()
        update_configuration_warnings()
@export var default_item_icon: Texture2D :
    get:
        return default_item_icon
    set(new_default_item_icon):
        if default_item_icon == new_default_item_icon:
            return
        default_item_icon = new_default_item_icon
        _refresh()
@export var icon_scaling: Vector2 = Vector2.ONE :
    get:
        return icon_scaling
    set(new_icon_scaling):
        if icon_scaling == new_icon_scaling:
            return
        icon_scaling = new_icon_scaling
        if _ctrl_inventory_item_rect && _ctrl_inventory_item_rect.texture:
            _ctrl_inventory_item_rect.custom_minimum_size = _ctrl_inventory_item_rect.texture.get_size() * icon_scaling
@export var item_texture_visible: bool = true :
    get:
        return item_texture_visible
    set(new_item_texture_visible):
        if item_texture_visible == new_item_texture_visible:
            return
        item_texture_visible = new_item_texture_visible
        if _ctrl_inventory_item_rect:
            _ctrl_inventory_item_rect.visible = item_texture_visible
@export var label_visible: bool = true :
    get:
        return label_visible
    set(new_label_visible):
        if label_visible == new_label_visible:
            return
        label_visible = new_label_visible
        if _label:
            _label.visible = label_visible
var item_slot: ItemSlot :
    get:
        return item_slot
    set(new_item_slot):
        if new_item_slot == item_slot:
            return

        _disconnect_item_slot_signals()
        item_slot = new_item_slot
        _connect_item_slot_signals()
        
        _refresh()
var _hbox_container: HBoxContainer
var _ctrl_inventory_item_rect: CtrlInventoryRect
var _label: Label
var _ctrl_drop_zone: CtrlDropZone


func _get_configuration_warnings() -> PackedStringArray:
    if item_slot_path.is_empty():
        return PackedStringArray([
            "This node is not linked to an item slot, so it can't display any content.\n" + \
            "Set the item_slot_path property to point to an ItemSlot node."])
    return PackedStringArray()


func _connect_item_slot_signals() -> void:
    if !item_slot:
        return

    if !item_slot.item_set.is_connected(_on_item_set):
        item_slot.item_set.connect(_on_item_set)
    if !item_slot.item_cleared.is_connected(_refresh):
        item_slot.item_cleared.connect(_refresh)
    if !item_slot.inventory_changed.is_connected(_on_inventory_changed):
        item_slot.inventory_changed.connect(_on_inventory_changed)


func _disconnect_item_slot_signals() -> void:
    if !item_slot:
        return

    if item_slot.item_set.is_connected(_on_item_set):
        item_slot.item_set.disconnect(_on_item_set)
    if item_slot.item_cleared.is_connected(_refresh):
        item_slot.item_cleared.disconnect(_refresh)
    if item_slot.inventory_changed.is_connected(_on_inventory_changed):
        item_slot.inventory_changed.disconnect(_on_inventory_changed)


func _on_item_set(_item: InventoryItem) -> void:
    _refresh()


func _on_inventory_changed(_inventory: Inventory) -> void:
    _refresh()


func _ready():
    if Engine.is_editor_hint():
        # Clean up, in case it is duplicated in the editor
        if _hbox_container:
            _hbox_container.queue_free()

    var node: Node = get_node_or_null(item_slot_path)
    if is_inside_tree() && node:
        assert(node is ItemSlot)
    item_slot = node

    _hbox_container = HBoxContainer.new()
    _hbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _hbox_container.size_flags_vertical = SIZE_EXPAND_FILL
    add_child(_hbox_container)
    _hbox_container.resized.connect(func(): size = _hbox_container.size)

    _ctrl_inventory_item_rect = CtrlInventoryRect.new()
    _ctrl_inventory_item_rect.visible = item_texture_visible
    _ctrl_inventory_item_rect.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    _ctrl_inventory_item_rect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    _ctrl_inventory_item_rect.item_slot = item_slot
    _ctrl_inventory_item_rect.resized.connect(func():
        custom_minimum_size = _ctrl_inventory_item_rect.size
        size = _ctrl_inventory_item_rect.size
    )
    _hbox_container.add_child(_ctrl_inventory_item_rect)

    _ctrl_drop_zone = CtrlDropZone.new()
    _ctrl_drop_zone.dragable_dropped.connect(_on_dragable_dropped)
    _ctrl_drop_zone.size = size
    resized.connect(func(): _ctrl_drop_zone.size = size)
    _ctrl_drop_zone.mouse_entered.connect(_on_drop_zone_mouse_entered)
    _ctrl_drop_zone.mouse_exited.connect(_on_drop_zone_mouse_exited)
    CtrlDragable.dragable_grabbed.connect(_on_any_dragable_grabbed)
    CtrlDragable.dragable_dropped.connect(_on_any_dragable_dropped)
    add_child(_ctrl_drop_zone)
    _ctrl_drop_zone.deactivate()

    _label = Label.new()
    _label.visible = label_visible
    _hbox_container.add_child(_label)

    size = _hbox_container.size
    _hbox_container.resized.connect(func(): size = _hbox_container.size)

    _refresh()


func _on_dragable_dropped(dragable: CtrlDragable, drop_position: Vector2) -> void:
    var item = (dragable as CtrlInventoryItemRect).item

    if !item:
        return
    if !item_slot:
        return
        
    if !item_slot.can_hold_item(item):
        return

    if item == item_slot.item:
        return

    if item.get_inventory() == null:
        if !item_slot.inventory.add_item(item):
            return
    elif item.get_inventory() != item_slot.inventory:
        if !item.get_inventory().transfer(item, item_slot.inventory):
            return

    item_slot.item = item


func _on_drop_zone_mouse_entered() -> void:
    if CtrlDragable._grabbed_dragable == null:
        return
    var _grabbed_ctrl := (CtrlDragable._grabbed_dragable as CtrlInventoryItemRect)
    if _grabbed_ctrl == null || _grabbed_ctrl.texture == null:
        return
    CtrlInventoryItemRect.override_preview_size(_grabbed_ctrl.texture.get_size() * icon_scaling)


func _on_drop_zone_mouse_exited() -> void:
    CtrlInventoryItemRect.restore_preview_size()


func _on_any_dragable_grabbed(dragable: CtrlDragable, grab_position: Vector2):
    _ctrl_drop_zone.activate()


func _on_any_dragable_dropped(dragable: CtrlDragable, zone: CtrlDropZone, drop_position: Vector2):
    _ctrl_drop_zone.deactivate()

    # Unequip from other slots
    if zone == _ctrl_drop_zone || zone == null:
        return
    var ctrl_inventory_item_rect := (dragable as CtrlInventoryItemRect)
    if ctrl_inventory_item_rect.item_slot:
        ctrl_inventory_item_rect.item_slot.item = null


func _refresh() -> void:
    _clear()

    if item_slot == null:
        return
    
    if item_slot.item == null:
        return

    var item = item_slot.item
    if _label:
        _label.text = item.get_property(CtrlInventory.KEY_NAME, item.prototype_id)
    if _ctrl_inventory_item_rect:
        _ctrl_inventory_item_rect.item = item
        _ctrl_inventory_item_rect.texture = item.get_texture()
        _ctrl_inventory_item_rect.custom_minimum_size = _ctrl_inventory_item_rect.texture.get_size() * icon_scaling


func _clear() -> void:
    if _label:
        _label.text = ""
    if _ctrl_inventory_item_rect:
        _ctrl_inventory_item_rect.item = null

