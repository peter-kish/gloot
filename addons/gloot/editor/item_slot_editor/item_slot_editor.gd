@tool
extends Control

const GlootUndoRedo = preload("res://addons/gloot/editor/gloot_undo_redo.gd")
const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")

@onready var hsplit_container = $HSplitContainer
@onready var prototype_id_filter = $HSplitContainer/ChoiceFilter
@onready var btn_edit = $HSplitContainer/VBoxContainer/HBoxContainer/BtnEdit
@onready var btn_clear = $HSplitContainer/VBoxContainer/HBoxContainer/BtnClear
@onready var ctrl_item_slot = $HSplitContainer/VBoxContainer/CtrlItemSlot

var item_slot: ItemSlot :
    set(new_item_slot):
        disconnect_item_slot_signals()
        item_slot = new_item_slot
        ctrl_item_slot.item_slot = item_slot
        connect_item_slot_signals()

        _refresh()


func connect_item_slot_signals():
    if !item_slot:
        return

    item_slot.item_equipped.connect(_refresh)
    item_slot.cleared.connect(_refresh)

    if !item_slot.item_protoset:
        return
    item_slot.item_protoset.changed.connect(_refresh)
    item_slot.protoset_changed.connect(_refresh)


func disconnect_item_slot_signals():
    if !item_slot:
        return
        
    item_slot.item_equipped.disconnect(_refresh)
    item_slot.cleared.disconnect(_refresh)

    if !item_slot.item_protoset:
        return
    item_slot.item_protoset.changed.disconnect(_refresh)
    item_slot.protoset_changed.disconnect(_refresh)


func init(item_slot_: ItemSlot) -> void:
    item_slot = item_slot_


func _refresh() -> void:
    if !is_inside_tree() || item_slot == null || item_slot.item_protoset == null:
        return
    prototype_id_filter.set_values(item_slot.item_protoset._prototypes.keys())


func _ready() -> void:
    _apply_editor_settings()

    prototype_id_filter.pick_icon = EditorIcons.get_icon("Add")
    prototype_id_filter.filter_icon = EditorIcons.get_icon("Search")
    btn_edit.icon = EditorIcons.get_icon("Edit")
    btn_clear.icon = EditorIcons.get_icon("Remove")

    prototype_id_filter.choice_picked.connect(_on_prototype_id_picked)
    btn_edit.pressed.connect(_on_btn_edit)
    btn_clear.pressed.connect(_on_btn_clear)

    ctrl_item_slot.item_slot = item_slot
    _refresh()


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    custom_minimum_size.y = control_height


func _on_prototype_id_picked(index: int) -> void:
    var prototype_id = prototype_id_filter.values[index]
    var item := InventoryItem.new()
    if item_slot.get_item() != null:
        item_slot.get_item().queue_free()
    item.protoset = item_slot.item_protoset
    item.prototype_id = prototype_id
    GlootUndoRedo.equip_item_in_item_slot(item_slot, item)
    

func _on_btn_edit() -> void:
    if item_slot.get_item() != null:
        # Call it deferred, so that the control can clean up
        call_deferred("_select_node", item_slot.get_item())


func _on_btn_clear() -> void:
    if item_slot.get_item() != null:
        item_slot.get_item().queue_free()
        GlootUndoRedo.clear_item_slot(item_slot)


static func _select_node(node: Node) -> void:
    EditorInterface.get_selection().clear()
    EditorInterface.get_selection().add_node(node)
    EditorInterface.edit_node(node)

