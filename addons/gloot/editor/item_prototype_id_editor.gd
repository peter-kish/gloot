extends EditorProperty


const ChoiceFilter = preload("res://addons/gloot/editor/choice_filter.tscn")
const EditorIcons = preload("res://addons/gloot/editor/editor_icons.gd")
const POPUP_SIZE = Vector2(300, 300)
const POPUP_MARGIN = 10
var current_value: String
var updating: bool = false
var _choice_filter: Control
var _window_dialog: WindowDialog
var _btn_prototype_id: Button
var gloot_undo_redo = null
var editor_interface: EditorInterface


func _init() -> void:
    _choice_filter = ChoiceFilter.instance()
    _choice_filter.pick_text = "Select"
    _choice_filter.filter_text = "Filter Prototypes:"
    _choice_filter.connect("choice_picked", self, "_on_choice_picked")

    _window_dialog = WindowDialog.new()
    _window_dialog.window_title = "Select Prototype ID"
    _window_dialog.resizable = true
    _window_dialog.rect_size = POPUP_SIZE
    add_child(_window_dialog)
    
    var _margin_container = MarginContainer.new()
    _margin_container.margin_bottom = -POPUP_MARGIN
    _margin_container.margin_left = POPUP_MARGIN
    _margin_container.margin_right = -POPUP_MARGIN
    _margin_container.margin_top = POPUP_MARGIN
    _margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _margin_container.size_flags_vertical = SIZE_EXPAND_FILL
    _margin_container.anchor_bottom = 1.0
    _margin_container.anchor_right = 1.0
    _margin_container.add_child(_choice_filter)
    _window_dialog.add_child(_margin_container)

    _btn_prototype_id = Button.new()
    _btn_prototype_id.text = "Prototype ID"
    _btn_prototype_id.connect("pressed", self, "_on_btn_prototype_id")
    add_child(_btn_prototype_id)


func _ready() -> void:
    _choice_filter.filter_icon = EditorIcons.get_icon(editor_interface, "Search")
    var item: InventoryItem = get_edited_object()
    item.connect("prototype_id_changed", self, "_on_prototype_id_changed")
    _refresh_button()


func _on_btn_prototype_id() -> void:
    _window_dialog.popup(Rect2(get_global_mouse_position(), POPUP_SIZE))


func _on_choice_picked(value_index: int) -> void:
    var item: InventoryItem = get_edited_object()
    var new_prototype_id = _choice_filter.values[value_index]
    if new_prototype_id != item.prototype_id:
        gloot_undo_redo.set_item_prototype_id(item, new_prototype_id)

    _window_dialog.hide()
    _refresh_button()


func _on_prototype_id_changed() -> void:
    _refresh_button()


func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if new_value == current_value:
        return

    updating = true
    current_value = new_value
    _refresh_choice_filter()
    _refresh_button()
    updating = false


func _refresh_choice_filter() -> void:
    _choice_filter.values = _get_prototype_ids()
    _choice_filter.refresh()


func _refresh_button() -> void:
    var item: InventoryItem = get_edited_object()
    _btn_prototype_id.text = item.prototype_id


func _get_prototype_ids() -> Array:
    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return []

    return item.protoset._prototypes.keys()
