extends Node
tool

signal item_dropped

var _editor_interface: EditorInterface = null
var _undo_redo: UndoRedo = null setget _set_undo_redo
var _gloot_undo_redo = null


func _set_undo_redo(new_undo_redo: UndoRedo) -> void:
    _undo_redo = new_undo_redo
    if _gloot_undo_redo == null:
        _gloot_undo_redo = preload("res://addons/gloot/editor/gloot_undo_redo.gd").new()


func _get_editor_icon(name: String) -> Texture:
    if _editor_interface:
        var gui = _editor_interface.get_base_control()
        var icon = gui.get_icon(name, "EditorIcons")
        return icon

    return null
