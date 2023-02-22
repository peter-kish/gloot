extends EditorProperty


const ChoiceFilter = preload("res://addons/gloot/editor/choice_filter.tscn")
const EditorIcons = preload("res://addons/gloot/editor/editor_icons.gd")
const POPUP_SIZE = Vector2i(300, 300)
const POPUP_MARGIN = 10
const COLOR_INVALID = Color.RED
var current_value: String
var updating: bool = false
var _choice_filter: Control
var _window_dialog: Window
var _btn_prototype_id: Button
var gloot_undo_redo = null
var editor_interface: EditorInterface


func _init():
    _choice_filter = ChoiceFilter.instantiate()
    _choice_filter.pick_text = "Select"
    _choice_filter.filter_text = "Filter Prototypes:"
    _choice_filter.connect("choice_picked", Callable(self, "_on_choice_picked"))

    _window_dialog = Window.new()
    _window_dialog.title = "Select Prototype ID"
    _window_dialog.unresizable = false
    _window_dialog.size = POPUP_SIZE
    _window_dialog.visible = false
    _window_dialog.borderless = true
    _window_dialog.popup_window = true
    _window_dialog.close_requested.connect(func(): _window_dialog.hide())
    add_child(_window_dialog)
    
    var _margin_container = MarginContainer.new()
    _margin_container.offset_bottom = -POPUP_MARGIN
    _margin_container.offset_left = POPUP_MARGIN
    _margin_container.offset_right = -POPUP_MARGIN
    _margin_container.offset_top = POPUP_MARGIN
    _margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _margin_container.size_flags_vertical = SIZE_EXPAND_FILL
    _margin_container.anchor_bottom = 1.0
    _margin_container.anchor_right = 1.0
    _margin_container.add_child(_choice_filter)
    _window_dialog.add_child(_margin_container)

    _btn_prototype_id = Button.new()
    _btn_prototype_id.text = "Prototype ID"
    _btn_prototype_id.connect("pressed", Callable(self, "_on_btn_prototype_id"))
    add_child(_btn_prototype_id)


func _ready() -> void:
    _choice_filter.filter_icon = EditorIcons.get_icon(editor_interface, "Search")
    var item: InventoryItem = get_edited_object()
    item.connect("prototype_id_changed", Callable(self, "_on_prototype_id_changed"))
    if item.protoset:
        item.protoset.connect("changed", Callable(self, "_on_protoset_changed"))
    _refresh_button()
    _refresh_choice_filter()


func _on_btn_prototype_id() -> void:
    # TODO: Figure out how to show a popup at mouse position
    # _window_dialog.popup(Rect2i(_get_popup_at_mouse_position(POPUP_SIZE), POPUP_SIZE))
    _window_dialog.popup_centered(POPUP_SIZE)

func _get_popup_at_mouse_position(size: Vector2i) -> Vector2i:
    var global_mouse_pos: Vector2i = Vector2i(get_global_mouse_position())
    var local_mouse_pos: Vector2i = global_mouse_pos + \
    DisplayServer.window_get_position(DisplayServer.MAIN_WINDOW_ID)
    
    # Prevent the popup from positioning partially out of screen
    var screen_size: Vector2i = DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
    var popup_pos: Vector2i
    popup_pos.x = clamp(local_mouse_pos.x, 0, screen_size.x - size.x)
    popup_pos.y = clamp(local_mouse_pos.y, 0, screen_size.y - size.y)

    return popup_pos


func _on_choice_picked(value_index: int) -> void:
    var item: InventoryItem = get_edited_object()
    var new_prototype_id = _choice_filter.values[value_index]
    if new_prototype_id != item.prototype_id:
        gloot_undo_redo.set_item_prototype_id(item, new_prototype_id)

    _window_dialog.hide()
    _refresh_button()


func _on_prototype_id_changed() -> void:
    _refresh_button()


func _on_protoset_changed() -> void:
    _refresh_button()
    _refresh_choice_filter()


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
    _choice_filter.values.clear()
    _choice_filter.values.append_array(_get_prototype_ids())
    _choice_filter.refresh()


func _refresh_button() -> void:
    var item: InventoryItem = get_edited_object()
    _btn_prototype_id.text = item.prototype_id
    if !item.protoset.has_prototype(item.prototype_id):
        _btn_prototype_id.add_theme_color_override("font_color", COLOR_INVALID)
        _btn_prototype_id.add_theme_color_override("font_color_hover", COLOR_INVALID)
        _btn_prototype_id.tooltip_text = "Invalid prototype ID!"
    else:
        _btn_prototype_id.remove_theme_color_override("font_color")
        _btn_prototype_id.remove_theme_color_override("font_color_hover")
        _btn_prototype_id.tooltip_text = ""


func _get_prototype_ids() -> Array:
    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return []

    return item.protoset._prototypes.keys()
