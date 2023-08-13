@tool
extends Button

const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")

@onready var window_dialog: Window = $"%Window"
@onready var protoset_editor: Control = $"%ProtosetEditor"

var protoset: ItemProtoset :
    get:
        return protoset
    set(new_protoset):
        protoset = new_protoset
        if protoset_editor:
            protoset_editor.protoset = protoset
var gloot_undo_redo = null :
    get:
        return gloot_undo_redo
    set(new_gloot_undo_redo):
        gloot_undo_redo = new_gloot_undo_redo
        if protoset_editor:
            protoset_editor.gloot_undo_redo = gloot_undo_redo
var editor_interface: EditorInterface :
    get:
        return editor_interface
    set(new_editor_interface):
        editor_interface = new_editor_interface
        if protoset_editor:
            protoset_editor.editor_interface = editor_interface


func init(protoset_: ItemProtoset, gloot_undo_redo_, editor_interface_: EditorInterface) -> void:
    protoset = protoset_
    gloot_undo_redo = gloot_undo_redo_
    editor_interface = editor_interface_


func _ready() -> void:
    icon = EditorIcons.get_icon(editor_interface, "Edit")
    window_dialog.close_requested.connect(Callable(self, "_on_close_requested"))
    protoset_editor.protoset = protoset
    protoset_editor.gloot_undo_redo = gloot_undo_redo
    protoset_editor.editor_interface = editor_interface
    pressed.connect(Callable(self, "_on_pressed"))


func _on_close_requested() -> void:
    protoset.notify_property_list_changed()


func _on_pressed() -> void:
    window_dialog.popup_centered(window_dialog.size)
