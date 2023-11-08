extends EditorProperty

const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const PropertiesEditor = preload("res://addons/gloot/editor/item_editor/properties_editor.tscn")
const POPUP_SIZE = Vector2i(800, 300)

var current_value: Dictionary
var updating: bool = false
var _btn_prototype_id: Button
var _properties_editor: Window


func _init():
    _properties_editor = PropertiesEditor.instantiate()
    add_child(_properties_editor)

    _btn_prototype_id = Button.new()
    _btn_prototype_id.text = "Edit Properties"
    _btn_prototype_id.pressed.connect(_on_btn_edit)
    _btn_prototype_id.icon = EditorIcons.get_icon("Edit")
    add_child(_btn_prototype_id)


func _ready() -> void:
    var item: InventoryItem = get_edited_object()
    if !item:
        return
    _properties_editor.item = item
    item.properties_changed.connect(update_property)

    if !item.protoset:
        return
    item.protoset.changed.connect(_on_protoset_changed)

    _refresh_button()


func _on_btn_edit() -> void:
    _properties_editor.popup_centered(POPUP_SIZE)


func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if new_value == current_value:
        return

    updating = true
    current_value = new_value
    updating = false


func _on_protoset_changed() -> void:
    _refresh_button()


func _refresh_button() -> void:
    var item: InventoryItem = get_edited_object()
    if !item || !item.protoset:
        return
    _btn_prototype_id.disabled = !item.protoset.has_prototype(item.prototype_id)

