@tool
extends Control

const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")

@onready var inventory_editor: Control = $HBoxContainer/InventoryEditor
@onready var btn_expand: Button = $HBoxContainer/BtnExpand
@onready var _window_dialog: Window = $Window
@onready var _inventory_editor: Control = $Window/MarginContainer/InventoryEditor

var inventory: Inventory :
    get:
        return inventory
    set(new_inventory):
        inventory = new_inventory
        if inventory_editor:
            inventory_editor.inventory = inventory
var editor_interface: EditorInterface :
    get:
        return editor_interface
    set(new_editor_interface):
        editor_interface = new_editor_interface
        if inventory_editor:
            inventory_editor.editor_interface = editor_interface
var gloot_undo_redo :
    get:
        return gloot_undo_redo
    set(new_gloot_undo_redo):
        gloot_undo_redo = new_gloot_undo_redo
        if inventory_editor:
            inventory_editor.gloot_undo_redo = gloot_undo_redo


func init(inventory_: Inventory, gloot_undo_redo_, editor_interface_: EditorInterface) -> void:
    inventory = inventory_
    gloot_undo_redo = gloot_undo_redo_
    editor_interface = editor_interface_


func _ready() -> void:
    if inventory_editor:
        inventory_editor.inventory = inventory
        inventory_editor.editor_interface = editor_interface
        inventory_editor.gloot_undo_redo = gloot_undo_redo
    _apply_editor_settings()
    btn_expand.icon = EditorIcons.get_icon(editor_interface, "DistractionFree")
    btn_expand.pressed.connect(Callable(self, "on_btn_expand"))
    _window_dialog.close_requested.connect(func(): _window_dialog.hide())


func on_btn_expand() -> void:
    _inventory_editor.inventory = inventory
    _inventory_editor.gloot_undo_redo = gloot_undo_redo
    _inventory_editor.editor_interface = editor_interface
    _window_dialog.popup_centered()


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    custom_minimum_size.y = control_height
