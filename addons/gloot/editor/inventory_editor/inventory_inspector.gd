@tool
extends Control

const _EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")

@onready var inventory_editor: Control = $HBoxContainer/InventoryEditor
@onready var btn_expand: Button = $HBoxContainer/BtnExpand
@onready var _window_dialog: Window = $Window
@onready var _inventory_editor: Control = $Window/MarginContainer/InventoryEditor

var inventory: Inventory:
    set(new_inventory):
        inventory = new_inventory
        if inventory_editor:
            inventory_editor.inventory = inventory


func init(inventory_: Inventory) -> void:
    inventory = inventory_


func _ready() -> void:
    if inventory_editor:
        inventory_editor.inventory = inventory
    _apply_editor_settings()
    btn_expand.icon = _EditorIcons.get_icon("DistractionFree")
    btn_expand.pressed.connect(on_btn_expand)
    _window_dialog.close_requested.connect(func(): _window_dialog.hide())


func on_btn_expand() -> void:
    _inventory_editor.inventory = inventory
    _window_dialog.popup_centered()


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    custom_minimum_size.y = control_height
