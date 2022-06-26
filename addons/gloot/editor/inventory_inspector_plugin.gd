extends EditorInspectorPlugin

signal edit_requested

var InventoryPropertyEditor = preload("res://addons/gloot/editor/inventory_property_editor.gd")
const INVENTORY_SCRIPT_PATH: String = "res://addons/gloot/inventory.gd"
var editor_interface: EditorInterface = null


func can_handle(object: Object) -> bool:
    var script: Script = object.get_script()
    if script == null:
        return false
        
    return _derives_from_inventory(script)


func _derives_from_inventory(a: Script) -> bool:
    if a.resource_path == INVENTORY_SCRIPT_PATH:
        return true

    var base_script = a.get_base_script()
    if base_script && base_script.resource_path == INVENTORY_SCRIPT_PATH:
        return true

    return false


func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int) -> bool:
    if path == "contents":
        var inventory_property_editor = InventoryPropertyEditor.new()
        inventory_property_editor.editor_interface = editor_interface
        add_property_editor(path, inventory_property_editor)
        return true
    return false

