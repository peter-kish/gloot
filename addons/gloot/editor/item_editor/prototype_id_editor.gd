extends Window

const ChoiceFilter = preload("res://addons/gloot/editor/common/choice_filter.tscn")
const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const POPUP_MARGIN = 10

var _choice_filter: Control
var _margin_container: MarginContainer
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



func _init(gloot_undo_redo_, editor_interface_: EditorInterface) -> void:
    assert(gloot_undo_redo_, "gloot_undo_redo_ is null!")
    assert(editor_interface_, "editor_interface_ is null!")
    gloot_undo_redo = gloot_undo_redo_
    editor_interface = editor_interface_

    title = "Select Prototype ID"
    unresizable = false
    visible = false
    borderless = true
    popup_window = true
    close_requested.connect(func(): hide())

    _choice_filter = ChoiceFilter.instantiate()
    _choice_filter.pick_text = "Select"
    _choice_filter.filter_text = "Filter Prototypes:"
    _choice_filter.choice_picked.connect(Callable(self, "_on_choice_picked"))

    _margin_container = MarginContainer.new()
    _margin_container.offset_bottom = -POPUP_MARGIN
    _margin_container.offset_left = POPUP_MARGIN
    _margin_container.offset_right = -POPUP_MARGIN
    _margin_container.offset_top = POPUP_MARGIN
    _margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _margin_container.anchor_bottom = 1.0
    _margin_container.anchor_right = 1.0
    _margin_container.add_child(_choice_filter)

    add_child(_margin_container)


func _on_choice_picked(value_index: int) -> void:
    assert(item, "Item not set!")
    var new_prototype_id = _choice_filter.values[value_index]
    if new_prototype_id != item.prototype_id:
        gloot_undo_redo.set_item_prototype_id(item, new_prototype_id)
    hide()


func _ready() -> void:
    _choice_filter.filter_icon = EditorIcons.get_icon(editor_interface, "Search")


func _refresh() -> void:
    _choice_filter.values.clear()
    _choice_filter.values.append_array(_get_prototype_ids())
    _choice_filter.refresh()


func _get_prototype_ids() -> Array:
    if item == null || !item.protoset:
        return []

    return item.protoset._prototypes.keys()

