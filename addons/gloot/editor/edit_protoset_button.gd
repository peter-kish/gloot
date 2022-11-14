extends Button
tool

const EditorIcons = preload("res://addons/gloot/editor/editor_icons.gd")

onready var window_dialog: WindowDialog = $"%WindowDialog"
onready var protoset_editor: Control = $"%ProtosetEditor"

var protoset: ItemProtoset setget _set_protoset
var gloot_undo_redo = null setget _set_gloot_undo_redo
var editor_interface: EditorInterface setget _set_editor_interface


func _set_protoset(new_protoset: ItemProtoset) -> void:
    protoset = new_protoset
    if protoset_editor:
        protoset_editor.protoset = protoset


func _set_gloot_undo_redo(new_gloot_undo_redo) -> void:
    gloot_undo_redo = new_gloot_undo_redo
    if protoset_editor:
        protoset_editor.gloot_undo_redo = gloot_undo_redo


func _set_editor_interface(new_editor_interface: EditorInterface) -> void:
    editor_interface = new_editor_interface
    if protoset_editor:
        protoset_editor.editor_interface = editor_interface


func _ready() -> void:
    icon = EditorIcons.get_icon(editor_interface, "Edit")
    window_dialog.connect("popup_hide", self, "_on_popup_hide")
    protoset_editor.protoset = protoset
    protoset_editor.gloot_undo_redo = gloot_undo_redo
    protoset_editor.editor_interface = editor_interface
    connect("pressed", self, "_on_pressed")


func _on_popup_hide() -> void:
    protoset.update_json_data()
    protoset.property_list_changed_notify()


func _on_pressed() -> void:
    window_dialog.popup_centered()