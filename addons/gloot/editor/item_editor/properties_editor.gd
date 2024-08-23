@tool
extends Window

const _Undoables = preload("res://addons/gloot/editor/undoables.gd")
const _DictEditor = preload("res://addons/gloot/editor/common/dict_editor.tscn")
const _EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const _COLOR_OVERRIDDEN = Color.GREEN
const _COLOR_INVALID = Color.RED

@onready var _margin_container: MarginContainer = $"MarginContainer"
@onready var _dict_editor: Control = $"MarginContainer/DictEditor"
var item: InventoryItem = null:
    set(new_item):
        if new_item == null:
            return
        item = new_item
        _refresh()


func _ready() -> void:
    about_to_popup.connect(func(): _refresh())
    close_requested.connect(func(): hide())
    _dict_editor.value_changed.connect(func(key: String, new_value): _on_value_changed(key, new_value))
    _dict_editor.value_removed.connect(func(key: String): _on_value_removed(key))
    hide()


func _on_value_changed(key: String, new_value) -> void:
    _Undoables.undoable_action(item, "Set Item Property", func():
        item.set_property(key, new_value)
        return true
    )
    # TODO: Figure out why this is needed
    _refresh.call_deferred()


func _on_value_removed(key: String) -> void:
    _Undoables.undoable_action(item, "Clear Item Property", func():
        item.clear_property(key)
        return true
    )
    _refresh()


func _refresh() -> void:
    if _dict_editor.btn_add:
        _dict_editor.btn_add.icon = _EditorIcons.get_icon("Add")
    _dict_editor.dictionary = _get_dictionary()
    _dict_editor.color_map = _get_color_map()
    _dict_editor.remove_button_map = _get_remove_button_map()
    _dict_editor.refresh()


func _get_dictionary() -> Dictionary:
    if item == null:
        return {}

    if item.get_prototree().is_empty():
        return {}

    if !item.get_prototree().has_prototype(item.get_prototype().get_prototype_id()):
        return {}

    var result: Dictionary = item.get_prototype().get_properties()
    for key in item.get_properties():
        result[key] = item.get_property(key)
    return result


func _get_color_map() -> Dictionary:
    if item == null:
        return {}

    if item.get_prototree().is_empty():
        return {}

    var result: Dictionary = {}
    var dictionary: Dictionary = _get_dictionary()
    for key in dictionary.keys():
        if item.is_property_overridden(key):
            result[key] = _COLOR_OVERRIDDEN

    return result
            

func _get_remove_button_map() -> Dictionary:
    if item == null:
        return {}

    if item.get_prototree().is_empty():
        return {}

    var result: Dictionary = {}
    var dictionary: Dictionary = _get_dictionary()
    for key in dictionary.keys():
        result[key] = {}
        if item.has_property(key):
            result[key]["text"] = ""
            result[key]["icon"] = _EditorIcons.get_icon("Reload")
        else:
            result[key]["text"] = ""
            result[key]["icon"] = _EditorIcons.get_icon("Remove")

        result[key]["disabled"] = not item.is_property_overridden(key)
    return result
