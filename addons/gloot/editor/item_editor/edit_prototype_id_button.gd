extends EditorProperty


const PrototypeIdEditor = preload("res://addons/gloot/editor/item_editor/prototype_id_editor.tscn")
const POPUP_SIZE = Vector2i(300, 300)
const COLOR_INVALID = Color.RED
var current_value: String
var updating: bool = false
var _prototype_id_editor: Window
var _btn_prototype_id: Button


func _init(gloot_undo_redo_, editor_interface_: EditorInterface):
    _prototype_id_editor = PrototypeIdEditor.instantiate()
    _prototype_id_editor.init(gloot_undo_redo_, editor_interface_)
    add_child(_prototype_id_editor)

    _btn_prototype_id = Button.new()
    _btn_prototype_id.text = "Prototype ID"
    _btn_prototype_id.pressed.connect(Callable(self, "_on_btn_prototype_id"))
    add_child(_btn_prototype_id)


func _ready() -> void:
    var item: InventoryItem = get_edited_object()
    _prototype_id_editor.item = item
    item.prototype_id_changed.connect(Callable(self, "_on_prototype_id_changed"))
    if item.protoset:
        item.protoset.changed.connect(Callable(self, "_on_protoset_changed"))
    _refresh_button()


func _on_btn_prototype_id() -> void:
    # TODO: Figure out how to show a popup at mouse position
    # _window_dialog.popup(Rect2i(_get_popup_at_mouse_position(POPUP_SIZE), POPUP_SIZE))
    _prototype_id_editor.popup_centered(POPUP_SIZE)


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


func _on_prototype_id_changed() -> void:
    _refresh_button()


func _on_protoset_changed() -> void:
    _refresh_button()


func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if new_value == current_value:
        return

    updating = true
    current_value = new_value
    _refresh_button()
    updating = false


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

