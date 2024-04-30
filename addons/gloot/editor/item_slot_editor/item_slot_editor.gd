@tool
extends Control

const Undoables = preload("res://addons/gloot/editor/undoables.gd")
const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const PropertiesEditor = preload("res://addons/gloot/editor/item_editor/properties_editor.tscn")
const POPUP_SIZE = Vector2i(800, 300)

var item_slot: ItemSlot :
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
    item_slot.cleared.connect(_refresh)

    if !item_slot.prototree_json:
        return
    item_slot.prototree_json.changed.connect(_refresh)
    item_slot.prototree_json_changed.connect(_refresh)


func disconnect_item_slot_signals():
    if !item_slot:
        return
        
    item_slot.item_equipped.disconnect(_refresh)
    item_slot.cleared.disconnect(_refresh)

    if !item_slot.prototree_json:
        return
    item_slot.prototree_json.changed.disconnect(_refresh)
    item_slot.prototree_json_changed.disconnect(_refresh)


func init(item_slot_: ItemSlot) -> void:
    item_slot = item_slot_


func _refresh() -> void:
    if !is_inside_tree() || item_slot == null || item_slot.prototree_json == null:
        return
    %PrototreeViewer.prototree_json = item_slot.prototree_json


func _ready() -> void:
    _apply_editor_settings()

    %BtnEdit.icon = EditorIcons.get_icon("Edit")
    %BtnClear.icon = EditorIcons.get_icon("Remove")

    %PrototreeViewer.prototype_activated.connect(_on_prototype_activated)
    %BtnEdit.pressed.connect(_on_btn_edit)
    %BtnClear.pressed.connect(_on_btn_clear)

    %CtrlItemSlot.item_slot = item_slot


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    custom_minimum_size.y = control_height


func _on_prototype_activated(prototype: Prototype) -> void:
    var item := InventoryItem.new()
    item.prototree_json = item_slot.prototree_json
    item.prototype_path = str(prototype.get_path())
    Undoables.exec_slot_undoable(item_slot, "Equip item", func():
        return item_slot.equip(item)
    )
    

func _on_btn_edit() -> void:
    if item_slot.get_item() == null:
        return
    if _properties_editor == null:
        _properties_editor = PropertiesEditor.instantiate()
        add_child(_properties_editor)
    _properties_editor.item = item_slot.get_item()
    _properties_editor.popup_centered(POPUP_SIZE)


func _on_btn_clear() -> void:
    if item_slot.get_item() != null:
        Undoables.exec_slot_undoable(item_slot, "Clear slot", func():
            return item_slot.clear()
        )


static func _select_node(node: Node) -> void:
    EditorInterface.get_selection().clear()
    EditorInterface.get_selection().add_node(node)
    EditorInterface.edit_node(node)

