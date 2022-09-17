extends Button
tool

onready var window_dialog: WindowDialog = $WindowDialog
onready var protoset_editor: Control = $WindowDialog/ProtosetEditor

var protoset: ItemProtoset setget _set_protoset


func _set_protoset(new_protoset: ItemProtoset) -> void:
    protoset = new_protoset
    if protoset_editor:
        protoset_editor.protoset = protoset


func _ready() -> void:
    protoset_editor.protoset = protoset
    connect("pressed", self, "_on_pressed")


func _on_pressed() -> void:
    window_dialog.popup_centered()