extends EditorProperty

const InventoryEditorControl = preload("res://addons/gloot/editor/inventory_editor_control.tscn")

var editor_interface: EditorInterface setget _set_editor_interface
var property_control: Control
var current_value
var updating: bool = false


func _set_editor_interface(new_interface: EditorInterface) -> void:
    editor_interface = new_interface
    if property_control:
        property_control.editor_interface = editor_interface


func _init() -> void:
    property_control = InventoryEditorControl.instance()
    property_control.editor_interface = editor_interface
    add_child(property_control)
    add_focusable(property_control)
    set_bottom_editor(property_control)
    property_control.refresh()


func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if new_value == current_value:
        return

    updating = true
    current_value = new_value
    property_control.inventory = get_edited_object()
    property_control.refresh()
    updating = false
