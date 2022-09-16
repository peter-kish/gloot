extends Control
tool

const EditorIcons = preload("res://addons/gloot/editor/editor_icons.gd")

onready var inventory_editor: Control = $HBoxContainer/InventoryEditor
onready var btn_expand: Button = $HBoxContainer/BtnExpand

var inventory: Inventory setget _set_inventory
var editor_interface: EditorInterface setget _set_editor_interface
var gloot_undo_redo setget _set_undo_redo


func _set_inventory(new_inventory: Inventory) -> void:
    inventory = new_inventory
    if inventory_editor:
        inventory_editor.inventory = inventory


func _set_editor_interface(new_editor_interface: EditorInterface) -> void:
    editor_interface = new_editor_interface
    if inventory_editor:
        inventory_editor.editor_interface = editor_interface


func _set_undo_redo(new_gloot_undo_redo) -> void:
    gloot_undo_redo = new_gloot_undo_redo
    if inventory_editor:
        inventory_editor.gloot_undo_redo = gloot_undo_redo


func _ready() -> void:
    if inventory_editor:
        inventory_editor.inventory = inventory
        inventory_editor.editor_interface = editor_interface
        inventory_editor.gloot_undo_redo = gloot_undo_redo
    _apply_editor_settings()
    btn_expand.icon = EditorIcons.get_icon(editor_interface, "DistractionFree")


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    rect_min_size.y = control_height