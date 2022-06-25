extends EditorInspectorPlugin

signal edit_requested

const INVENTORY_SCRIPT_PATH: String = "res://addons/gloot/inventory.gd"
const InventoryEditorControl = preload("res://addons/gloot/editor/inventory_editor_control.tscn")
var inventory: Inventory = null
var editor_interface: EditorInterface = null


func can_handle(object: Object) -> bool:
    var script: Script = object.get_script()

    if script && _derives_from_inventory(script):
        var editor_control = InventoryEditorControl.instance()
        editor_control.inventory = object
        editor_control.editor_interface = editor_interface
        add_custom_control(editor_control)
        return true

    return false


func _derives_from_inventory(a: Script) -> bool:
    if a.resource_path == INVENTORY_SCRIPT_PATH:
        return true

    var base_script = a.get_base_script()
    if base_script && base_script.resource_path == INVENTORY_SCRIPT_PATH:
        return true

    return false

