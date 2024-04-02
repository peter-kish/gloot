@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin
static var _instance: EditorPlugin


func _init() -> void:
    _instance = self


static func instance() -> EditorPlugin:
    return _instance


func _enter_tree() -> void:
    inspector_plugin = preload("res://addons/gloot/editor/inventory_inspector_plugin.gd").new()
    add_inspector_plugin(inspector_plugin)

    _add_settings()


func _exit_tree() -> void:
    remove_inspector_plugin(inspector_plugin)

func _add_settings() -> void:
    _add_setting("gloot/inspector_control_height", TYPE_INT, 200)
    _add_setting("gloot/item_dragging_deadzone_radius", TYPE_FLOAT, 8.0)
    _add_setting("gloot/JSON_serialization/indent_using_spaces", TYPE_BOOL, true)
    _add_setting("gloot/JSON_serialization/indent_size", TYPE_INT, 4)
    _add_setting("gloot/JSON_serialization/sort_keys", TYPE_BOOL, true)
    _add_setting("gloot/JSON_serialization/full_precision", TYPE_BOOL, false)


func _add_setting(name: String, type: int, value) -> void:
    if !ProjectSettings.has_setting(name):
        ProjectSettings.set(name, value)

    var property_info = {
        "name": name,
        "type": type
    }
    ProjectSettings.add_property_info(property_info)
    ProjectSettings.set_initial_value(name, value)
