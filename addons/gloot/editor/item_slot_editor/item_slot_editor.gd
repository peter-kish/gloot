@tool
extends Control

const _Undoables = preload("res://addons/gloot/editor/undoables.gd")
const _EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const _PropertiesEditor = preload("res://addons/gloot/editor/item_editor/properties_editor.tscn")
const _POPUP_SIZE = Vector2i(800, 300)

var item_slot: ItemSlot:
    set(new_item_slot):
        disconnect_item_slot_signals()
        item_slot = new_item_slot
        %CtrlItemSlot.item_slot = item_slot
        connect_item_slot_signals()

        _refresh()

var _properties_editor: Window


func connect_item_slot_signals():
    if !item_slot:
        return

    item_slot.item_equipped.connect(_refresh)
    item_slot.cleared.connect(_on_item_slot_cleared)

    if !item_slot.protoset:
        return
    item_slot.protoset.changed.connect(_refresh)
    item_slot.protoset_changed.connect(_refresh)


func disconnect_item_slot_signals():
    if !item_slot:
        return
        
    item_slot.item_equipped.disconnect(_refresh)
    item_slot.cleared.disconnect(_on_item_slot_cleared)

    if !item_slot.protoset:
        return
    item_slot.protoset.changed.disconnect(_refresh)
    item_slot.protoset_changed.disconnect(_refresh)


func _on_item_slot_cleared(item: InventoryItem) -> void:
    _refresh()


func init(item_slot_: ItemSlot) -> void:
    item_slot = item_slot_


func _refresh() -> void:
    if !is_inside_tree() || item_slot == null || item_slot.protoset == null:
        return
    %PrototreeViewer.protoset = item_slot.protoset


func _ready() -> void:
    _apply_editor_settings()

    %BtnAdd.icon = _EditorIcons.get_icon("Add")
    %BtnEdit.icon = _EditorIcons.get_icon("Edit")
    %BtnClear.icon = _EditorIcons.get_icon("Remove")

    %PrototreeViewer.prototype_activated.connect(_on_prototype_activated)
    %BtnAdd.pressed.connect(_on_btn_add)
    %BtnEdit.pressed.connect(_on_btn_edit)
    %BtnClear.pressed.connect(_on_btn_clear)

    %CtrlItemSlot.item_slot = item_slot


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    custom_minimum_size.y = control_height


func _on_prototype_activated(prototype: Prototype) -> void:
    var item := InventoryItem.new(item_slot.protoset, prototype.get_prototype_id())
    _Undoables.undoable_action(item_slot, "Equip item", func():
        return item_slot.equip(item)
    )


func _on_btn_add() -> void:
    var prototype: Prototype = %PrototreeViewer.get_selected_prototype()
    if prototype == null:
        return
    var item := InventoryItem.new(item_slot.protoset, prototype.get_prototype_id())
    _Undoables.undoable_action(item_slot, "Equip item", func():
        return item_slot.equip(item)
    )
    

func _on_btn_edit() -> void:
    if item_slot.get_item() == null:
        return
    if _properties_editor == null:
        _properties_editor = _PropertiesEditor.instantiate()
        add_child(_properties_editor)
    _properties_editor.item = item_slot.get_item()
    _properties_editor.popup_centered(_POPUP_SIZE)


func _on_btn_clear() -> void:
    if item_slot.get_item() != null:
        _Undoables.undoable_action(item_slot, "Clear slot", func():
            return item_slot.clear()
        )


static func _select_node(node: Node) -> void:
    EditorInterface.get_selection().clear()
    EditorInterface.get_selection().add_node(node)
    EditorInterface.edit_node(node)
