extends EditorInspectorPlugin

signal edit_requested

var InventoryCustomControl = preload("res://addons/gloot/editor/inventory_custom_control.tscn")
var editor_interface: EditorInterface = null


func can_handle(object: Object) -> bool:
    return object is Inventory


func parse_begin(object: Object) -> void:
    var inventory_custom_control = InventoryCustomControl.instance()
    inventory_custom_control.inventory = object
    add_custom_control(inventory_custom_control)

