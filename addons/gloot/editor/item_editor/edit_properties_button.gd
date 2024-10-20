extends Button

const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const PropertiesEditor = preload("res://addons/gloot/editor/item_editor/properties_editor.tscn")
const POPUP_SIZE = Vector2i(800, 300)

var item: InventoryItem
var _properties_editor: Window


func _ready() -> void:
    _properties_editor = PropertiesEditor.instantiate()
    add_child(_properties_editor)

    text = "Edit Item Properties"
    pressed.connect(_on_btn_edit)
    icon = EditorIcons.get_icon("Edit")

    if !item:
        return
    _properties_editor.item = item

    if !item.protoset:
        return
    item.protoset.changed.connect(_on_protoset_changed)

    _refresh()


func _on_btn_edit() -> void:
    _properties_editor.popup_centered(POPUP_SIZE)


func _on_protoset_changed() -> void:
    _refresh()


func _refresh() -> void:
    if !item || !item.protoset:
        return
    disabled = !item.protoset.has_prototype(item.prototype_id)
