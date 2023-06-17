@tool
class_name CtrlItemSlot
extends Control


@export var item_slot_path: NodePath :
    get:
        return item_slot_path
    set(new_item_slot_path):
        item_slot_path = new_item_slot_path
        var node: Node = get_node_or_null(item_slot_path)
        
        if node == null:
            return

        if is_inside_tree():
            assert(node is ItemSlot)
            
        self.item_slot = node
        update_configuration_warnings()
@export var default_item_icon: Texture2D :
    get:
        return default_item_icon
    set(new_default_item_icon):
        default_item_icon = new_default_item_icon
        _refresh()
@export var item_texture_visible: bool = true :
    get:
        return item_texture_visible
    set(new_item_texture_visible):
        item_texture_visible = new_item_texture_visible
        if _texture_rect:
            _texture_rect.visible = item_texture_visible
@export var label_visible: bool = true :
    get:
        return label_visible
    set(new_label_visible):
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
var _texture_rect: TextureRect
var _label: Label
var _gloot: Node = null


func _get_configuration_warnings() -> PackedStringArray:
    if item_slot_path.is_empty():
        return PackedStringArray([
            "This node is not linked to an item slot, so it can't display any content.\n" + \
            "Set the item_slot_path property to point to an ItemSlot node."])
    return PackedStringArray()


func _connect_item_slot_signals() -> void:
    if !item_slot:
        return

    if !item_slot.item_set.is_connected(Callable(self, "_on_item_set")):
        item_slot.item_set.connect(Callable(self, "_on_item_set"))
    if !item_slot.item_cleared.is_connected(Callable(self, "_refresh")):
        item_slot.item_cleared.connect(Callable(self, "_refresh"))
    if !item_slot.inventory_changed.is_connected(Callable(self, "_on_inventory_changed")):
        item_slot.inventory_changed.connect(Callable(self, "_on_inventory_changed"))


func _disconnect_item_slot_signals() -> void:
    if !item_slot:
        return

    if item_slot.item_set.is_connected(Callable(self, "_on_item_set")):
        item_slot.item_set.disconnect(Callable(self, "_on_item_set"))
    if item_slot.item_cleared.is_connected(Callable(self, "_refresh")):
        item_slot.item_cleared.disconnect(Callable(self, "_refresh"))
    if item_slot.inventory_changed.is_connected(Callable(self, "_on_inventory_changed")):
        item_slot.inventory_changed.disconnect(Callable(self, "_on_inventory_changed"))


func _on_item_set(_item: InventoryItem) -> void:
    _refresh()


func _on_inventory_changed(_inventory: Inventory) -> void:
    _refresh()


func _ready():
    _gloot = _get_gloot()

    if Engine.is_editor_hint():
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
    self.item_slot = node

    _refresh()
    if !Engine.is_editor_hint() && _gloot:
        _gloot.item_dropped.connect(Callable(self, "_on_item_dropped"))


func _get_gloot() -> Node:
    # This is a "temporary" hack until a better solution is found!
    # This is a tool script that is also executed inside the editor, where the "GLoot" singleton is
    # not visible - leading to errors inside the editor.
    # To work around that, we obtain the singleton by name.
    return get_tree().root.get_node_or_null("GLoot")


func _get_singleton() -> Node:
    return null


func _on_item_dropped(wr_item: WeakRef, global_drop_pos: Vector2) -> void:
    var item: InventoryItem = wr_item.get_ref()
    if !item:
        return
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

