@tool
extends Window

const ChoiceFilter = preload("res://addons/gloot/editor/common/choice_filter.tscn")
const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const POPUP_MARGIN = 10

@onready var _margin_container: MarginContainer = $"MarginContainer"
@onready var _choice_filter: Control = $"MarginContainer/ChoiceFilter"
var gloot_undo_redo = null
var editor_interface: EditorInterface
var item: InventoryItem = null :
    get:
        return item
    set(new_item):
        if new_item == null:
            return
        assert(item == null, "Item already set!")
        item = new_item
        if item.protoset:
            item.protoset.changed.connect(Callable(self, "_refresh"))
        _refresh()


func init(gloot_undo_redo_, editor_interface_: EditorInterface) -> void:
    assert(gloot_undo_redo_, "gloot_undo_redo_ is null!")
    assert(editor_interface_, "editor_interface_ is null!")
    gloot_undo_redo = gloot_undo_redo_
    editor_interface = editor_interface_


func _ready() -> void:
    _choice_filter.filter_icon = EditorIcons.get_icon(editor_interface, "Search")
    about_to_popup.connect(func(): _refresh())
    close_requested.connect(func(): hide())
    _choice_filter.choice_picked.connect(func(value_index: int): _on_choice_picked(value_index))
    hide()


func _on_choice_picked(value_index: int) -> void:
    assert(item, "Item not set!")
    var new_prototype_id = _choice_filter.values[value_index]
    if new_prototype_id != item.prototype_id:
        gloot_undo_redo.set_item_prototype_id(item, new_prototype_id)
    hide()


func _refresh() -> void:
    _choice_filter.values.clear()
    _choice_filter.values.append_array(_get_prototype_ids())
    _choice_filter.refresh()


func _get_prototype_ids() -> Array:
    if item == null || !item.protoset:
        return []

    return item.protoset._prototypes.keys()

