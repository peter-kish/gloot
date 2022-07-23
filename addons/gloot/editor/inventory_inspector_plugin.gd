extends EditorInspectorPlugin

signal edit_requested

var InventoryCustomControl = preload("res://addons/gloot/editor/inventory_custom_control.tscn")
var ItemPropertyEditor = preload("res://addons/gloot/editor/item_property_editor.gd")
var editor_interface: EditorInterface = null


func can_handle(object: Object) -> bool:
    return (object is Inventory) || (object is InventoryItem)


func parse_begin(object: Object) -> void:
    if object is Inventory:
        var inventory_custom_control = InventoryCustomControl.instance()
        inventory_custom_control.inventory = object
        inventory_custom_control.editor_interface = editor_interface
        add_custom_control(inventory_custom_control)


func parse_property(object, type, path, hint, hint_text, usage) -> bool:
    if (object is InventoryItem) && path == "properties":
        var item_property_editor =ItemPropertyEditor.new()
        add_property_editor(path, item_property_editor)
        return true
    return false

