class_name CtrlItemSlot
extends HBoxContainer
tool


export(NodePath) var item_slot_path: NodePath setget _set_item_slot_path
export(Texture) var default_item_icon: Texture
export(bool) var item_texture_visible = true setget _set_item_texture_visible
export(bool) var label_visible = true setget _set_label_visible
var item_slot: ItemSlot setget _set_item_slot
var _texture_rect: TextureRect
var _label: Label


func _set_item_slot_path(new_item_slot_path: NodePath) -> void:
    item_slot_path = new_item_slot_path
    var node: Node = get_node_or_null(item_slot_path)

    if is_inside_tree():
        assert(node is ItemSlot)
        
    _set_item_slot(node)


func _set_item_texture_visible(new_item_texture_visible: bool) -> void:
    item_texture_visible = new_item_texture_visible
    if _texture_rect:
        _texture_rect.visible = item_texture_visible


func _set_label_visible(new_label_visible: bool) -> void:
    label_visible = new_label_visible
    if _label:
        _label.visible = label_visible


func _set_item_slot(new_item_slot: ItemSlot) -> void:
    if new_item_slot == null && item_slot:
        _disconnect_signals()

    item_slot = new_item_slot

    if item_slot:
        _refresh()
        _connect_signals()


func _connect_signals() -> void:
    item_slot.connect("item_set", self, "_on_item_set")
    item_slot.connect("item_cleared", self, "_refresh")
    item_slot.connect("inventory_changed", self, "_on_inventory_changed")


func _disconnect_signals() -> void:
    item_slot.disconnect("item_set", self, "_on_item_set")
    item_slot.disconnect("item_cleared", self, "_refresh")
    item_slot.disconnect("inventory_changed", self, "_on_inventory_changed")


func _on_item_set(_item: InventoryItem) -> void:
    _refresh()


func _on_inventory_changed(_inventory: Inventory) -> void:
    _refresh()


func _ready():
    _texture_rect = TextureRect.new()
    _texture_rect.visible = item_texture_visible
    add_child(_texture_rect)

    _label = Label.new()
    _label.visible = label_visible
    add_child(_label)

    var node: Node = get_node_or_null(item_slot_path)
    if is_inside_tree():
        assert(node is ItemSlot)
    _set_item_slot(node)

    _refresh()


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
        _texture_rect.texture = _get_item_texture(item)


func _clear() -> void:
    if _label:
        _label.text = ""
    if _texture_rect:
        _texture_rect.texture = default_item_icon


func _get_item_texture(item: InventoryItem) -> Resource:
    var texture_path = item.get_property(CtrlInventory.KEY_IMAGE)
    if texture_path:
        return load(texture_path)
    return default_item_icon
