class_name CtrlItemSlot
extends Control
tool


export(NodePath) var item_slot_path: NodePath setget _set_item_slot_path
export(Texture) var default_item_icon: Texture setget _set_default_item_icon
export(bool) var item_texture_visible: bool = true setget _set_item_texture_visible
export(bool) var label_visible: bool = true setget _set_label_visible
var item_slot: ItemSlot setget _set_item_slot
var _hbox_container: HBoxContainer
var _texture_rect: TextureRect
var _label: Label
var _gloot: Node = null


func _get_configuration_warning() -> String:
    if item_slot_path.is_empty():
        return "This node is not linked to an item slot, so it can't display any content.\n" + \
               "Set the item_slot_path property to point to an ItemSlot node."
    return ""


func _set_item_slot_path(new_item_slot_path: NodePath) -> void:
    item_slot_path = new_item_slot_path
    var node: Node = get_node_or_null(item_slot_path)

    if is_inside_tree() && node:
        assert(node is ItemSlot)
        
    _set_item_slot(node)
    update_configuration_warning()


func _set_default_item_icon(new_default_item_icon: Texture) -> void:
    default_item_icon = new_default_item_icon
    _refresh()


func _set_item_texture_visible(new_item_texture_visible: bool) -> void:
    item_texture_visible = new_item_texture_visible
    if _texture_rect:
        _texture_rect.visible = item_texture_visible


func _set_label_visible(new_label_visible: bool) -> void:
    label_visible = new_label_visible
    if _label:
        _label.visible = label_visible


func _set_item_slot(new_item_slot: ItemSlot) -> void:
    if new_item_slot == item_slot:
        return

    _disconnect_item_slot_signals()
    item_slot = new_item_slot
    _connect_item_slot_signals()
    
    _refresh()


func _connect_item_slot_signals() -> void:
    if !item_slot:
        return

    if !item_slot.is_connected("item_set", self, "_on_item_set"):
        item_slot.connect("item_set", self, "_on_item_set")
    if !item_slot.is_connected("item_cleared", self, "_refresh"):
        item_slot.connect("item_cleared", self, "_refresh")
    if !item_slot.is_connected("inventory_changed", self, "_on_inventory_changed"):
        item_slot.connect("inventory_changed", self, "_on_inventory_changed")


func _disconnect_item_slot_signals() -> void:
    if !item_slot:
        return

    if item_slot.is_connected("item_set", self, "_on_item_set"):
        item_slot.disconnect("item_set", self, "_on_item_set")
    if item_slot.is_connected("item_cleared", self, "_refresh"):
        item_slot.disconnect("item_cleared", self, "_refresh")
    if item_slot.is_connected("inventory_changed", self, "_on_inventory_changed"):
        item_slot.disconnect("inventory_changed", self, "_on_inventory_changed")


func _on_item_set(_item: InventoryItem) -> void:
    _refresh()


func _on_inventory_changed(_inventory: Inventory) -> void:
    _refresh()


func _ready():
    _gloot = _get_gloot()

    if Engine.editor_hint:
        # Clean up, in case it is duplicated in the editor
        if _hbox_container:
            _hbox_container.queue_free()

    _hbox_container = HBoxContainer.new()
    _hbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _hbox_container.size_flags_vertical = SIZE_EXPAND_FILL
    add_child(_hbox_container)

    _texture_rect = TextureRect.new()
    _texture_rect.visible = item_texture_visible
    _hbox_container.add_child(_texture_rect)

    _label = Label.new()
    _label.visible = label_visible
    _hbox_container.add_child(_label)

    var node: Node = get_node_or_null(item_slot_path)
    if is_inside_tree() && node:
        assert(node is ItemSlot)
    _set_item_slot(node)

    _refresh()
    if !Engine.editor_hint && _gloot:
        _gloot.connect("item_dropped", self, "_on_item_dropped")


func _get_gloot() -> Node:
    # This is a "temporary" hack until a better solution is found!
    # This is a tool script that is also executed inside the editor, where the "GLoot" singleton is
    # not visible - leading to errors inside the editor.
    # To work around that, we obtain the singleton by name.
    return get_tree().root.get_node_or_null("GLoot")


func _get_singleton() -> Node:
    return null


func _on_item_dropped(item: InventoryItem, global_drop_pos: Vector2) -> void:
    if !item_slot:
        return
        
    var slot_rect = get_global_rect()
    if slot_rect.has_point(get_global_mouse_position()) && item_slot.can_hold_item(item):
        item_slot.item = item


func _refresh() -> void:
    _clear()

    if item_slot == null:
        return
    
    if item_slot.item == null:
        return

    var item = item_slot.item
    if _label:
        _label.text = item.get_property(CtrlInventory.KEY_NAME, item.prototype_id)
    if _texture_rect:
        _texture_rect.texture = item.get_texture()


func _clear() -> void:
    if _label:
        _label.text = ""
    if _texture_rect:
        _texture_rect.texture = null

