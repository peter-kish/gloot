@tool
extends Button

const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")

@onready var window_dialog: Window = $"%Window"
@onready var protoset_editor: Control = $"%ProtosetEditor"

var protoset: ItemProtoset :
    set(new_protoset):
        protoset = new_protoset
        if protoset_editor:
            protoset_editor.protoset = protoset


func init(protoset_: ItemProtoset) -> void:
    protoset = protoset_


func _ready() -> void:
    icon = EditorIcons.get_icon("Edit")
    window_dialog.close_requested.connect(func(): protoset.notify_property_list_changed())
    protoset_editor.protoset = protoset
    pressed.connect(func(): window_dialog.popup_centered(window_dialog.size))

