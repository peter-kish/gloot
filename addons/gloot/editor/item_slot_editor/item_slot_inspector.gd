@tool
extends Control

const _EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")

@onready var item_slot_editor: Control = $HBoxContainer/ItemSlotEditor
@onready var btn_expand: Button = $HBoxContainer/BtnExpand
@onready var _window_dialog: Window = $Window
@onready var _item_slot_editor: Control = $Window/MarginContainer/ItemSlotEditor

var item_slot: ItemSlot:
    set(new_item_slot):
        item_slot = new_item_slot
        if item_slot_editor:
            item_slot_editor.item_slot = item_slot


func init(item_slot_: ItemSlot) -> void:
    item_slot = item_slot_


func _ready() -> void:
    if item_slot_editor:
        item_slot_editor.item_slot = item_slot
    _apply_editor_settings()
    btn_expand.icon = _EditorIcons.get_icon("DistractionFree")
    btn_expand.pressed.connect(on_btn_expand)
    _window_dialog.close_requested.connect(func(): _window_dialog.hide())


func on_btn_expand() -> void:
    _item_slot_editor.item_slot = item_slot
    _window_dialog.popup_centered()


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    custom_minimum_size.y = control_height
