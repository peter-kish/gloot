@tool
extends Control

signal value_changed(key, value)
signal value_removed(key)

const Verify = preload("res://addons/gloot/core/verify.gd")
const ValueEditor = preload("res://addons/gloot/editor/common/value_editor.gd")
const supported_types: Array[int] = [
    TYPE_BOOL,
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_VECTOR2,
    TYPE_VECTOR2I,
    TYPE_RECT2,
    TYPE_RECT2I,
    TYPE_VECTOR3,
    TYPE_VECTOR3I,
    TYPE_PLANE,
    TYPE_QUATERNION,
    TYPE_AABB,
    TYPE_COLOR,
]

@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer
@onready var lbl_name = $VBoxContainer/ScrollContainer/GridContainer/LblTitleName
@onready var lbl_type = $VBoxContainer/ScrollContainer/GridContainer/LblTitleType
@onready var lbl_value = $VBoxContainer/ScrollContainer/GridContainer/LblTitleValue
@onready var ctrl_dummy = $VBoxContainer/ScrollContainer/GridContainer/CtrlDummy
@onready var edt_property_name = $VBoxContainer/HBoxContainer/EdtPropertyName
@onready var opt_type = $VBoxContainer/HBoxContainer/OptType
@onready var btn_add = $VBoxContainer/HBoxContainer/BtnAdd

@export var dictionary: Dictionary :
    get:
        return dictionary
    set(new_dictionary):
        dictionary = new_dictionary
        refresh()
@export var color_map: Dictionary :
    get:
        return color_map
    set(new_color_map):
        color_map = new_color_map
        refresh()
@export var remove_button_map: Dictionary :
    get:
        return remove_button_map
    set(new_remove_button_map):
        remove_button_map = new_remove_button_map
        refresh()
@export var immutable_keys: Array[String] :
    get:
        return immutable_keys
    set(new_immutable_keys):
        immutable_keys = new_immutable_keys
        refresh()
@export var default_color: Color = Color.WHITE :
    get:
        return default_color
    set(new_default_color):
        default_color = new_default_color
        refresh()


func _ready() -> void:
    btn_add.pressed.connect(Callable(self, "_on_btn_add"))
    edt_property_name.text_submitted.connect(Callable(self, "_on_text_entered"))
    refresh()


func _on_btn_add() -> void:
    var name: String = edt_property_name.text
    var type: int = opt_type.get_selected_id()
    if _add_dict_field(name, type):
        value_changed.emit(name, dictionary[name])
    refresh()


func _on_text_entered(_new_text: String) -> void:
    _on_btn_add()


func _add_dict_field(name: String, type: int) -> bool:
    if (name.is_empty() || type < 0 || dictionary.has(name)):
        return false
    dictionary[name] = Verify.create_var(type)
    return true


func refresh() -> void:
    if !is_inside_tree():
        return
    _clear()
    lbl_name.add_theme_color_override("font_color", default_color)
    lbl_type.add_theme_color_override("font_color", default_color)
    lbl_value.add_theme_color_override("font_color", default_color)

    _refresh_add_property()
    _populate()


func _refresh_add_property() -> void:
    for type in supported_types:
        opt_type.add_item(Verify.type_names[type], type)
    opt_type.select(supported_types.find(TYPE_STRING))


func _clear() -> void:
    edt_property_name.text = ""
    opt_type.clear()

    for child in grid_container.get_children():
        if (child == lbl_name) || (child == lbl_type) || (child == lbl_value) || (child == ctrl_dummy):
            continue
        child.queue_free()


func _populate() -> void:
    for key in dictionary.keys():
        var color: Color = default_color
        if color_map.has(key) && typeof(color_map[key]) == TYPE_COLOR:
            color = color_map[key]

        _add_key(key, color)


func _add_key(key: String, color: Color) -> void:
    if !(key is String):
        return

    var value = dictionary[key]
    _add_label(key, color)
    _add_label(Verify.type_names[typeof(dictionary[key])], color)
    _add_value_editor(key)
    _add_remove_button(key)


func _add_label(key: String, color: Color) -> void:
    var label: Label = Label.new()
    label.text = key
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_color_override("font_color", color)
    grid_container.add_child(label)


func _add_value_editor(key: String) -> void:
    var value_editor: Control = ValueEditor.new()
    value_editor.value = dictionary[key]
    value_editor.size_flags_horizontal = SIZE_EXPAND_FILL
    value_editor.enabled = (not key in immutable_keys)
    value_editor.value_changed.connect(Callable(self, "_on_value_changed").bind(key, value_editor))
    grid_container.add_child(value_editor)


func _on_value_changed(key: String, value_editor: Control) -> void:
    dictionary[key] = value_editor.value
    value_changed.emit(key, value_editor.value)


func _add_remove_button(key: String) -> void:
    var button: Button = Button.new()
    button.text = "Remove"
    if remove_button_map.has(key):
        button.text = remove_button_map[key].text
        button.disabled = remove_button_map[key].disabled
        button.icon = remove_button_map[key].icon
    button.pressed.connect(Callable(self, "_on_remove_button").bind(key))
    grid_container.add_child(button)


func _on_remove_button(key: String) -> void:
    dictionary.erase(key)
    value_removed.emit(key)
    refresh()


func set_remove_button_config(key: String, config: Dictionary) -> void:
    remove_button_map[key] = config
    refresh()
