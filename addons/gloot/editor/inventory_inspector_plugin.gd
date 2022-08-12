extends EditorInspectorPlugin

signal edit_requested

var InventoryCustomControl = preload("res://addons/gloot/editor/inventory_custom_control.tscn")
var ItemPropertyEditor = preload("res://addons/gloot/editor/item_property_editor.gd")
var ItemPrototypeIdEditor = preload("res://addons/gloot/editor/item_prototype_id_editor.gd")
var ItemSlotEquippedItemEditor = preload("res://addons/gloot/editor/item_slot_equipped_item_editor.gd")
var editor_interface: EditorInterface = null
var undo_redo: UndoRedo = null


func can_handle(object: Object) -> bool:
    return (object is Inventory) || (object is InventoryItem) || (object is ItemSlot)


func parse_begin(object: Object) -> void:
    if object is Inventory:
        var inventory_custom_control = InventoryCustomControl.instance()
        inventory_custom_control.inventory = object
        inventory_custom_control.editor_interface = editor_interface
        inventory_custom_control.undo_redo = undo_redo
        add_custom_control(inventory_custom_control)


func parse_property(object, type, path, hint, hint_text, usage) -> bool:
    if (object is InventoryItem) && path == "properties":
        var item_property_editor =ItemPropertyEditor.new()
        item_property_editor.undo_redo = undo_redo
        add_property_editor(path, item_property_editor)
        return true
    if (object is InventoryItem) && path == "prototype_id":
        var item_prototype_id_editor =ItemPrototypeIdEditor.new()
        item_prototype_id_editor.undo_redo = undo_redo
        add_property_editor(path, item_prototype_id_editor)
        return true
    if (object is ItemSlot) && path == "equipped_item":
        var item_slot_equipped_item_editor =ItemSlotEquippedItemEditor.new()
        item_slot_equipped_item_editor.undo_redo = undo_redo
        add_property_editor(path, item_slot_equipped_item_editor)
        return true
    return false

