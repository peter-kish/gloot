extends EditorInspectorPlugin

var EditProtosetButton = preload("res://addons/gloot/editor/edit_protoset_button.tscn")
var InventoryInspector = preload("res://addons/gloot/editor/inventory_inspector.tscn")
var ItemPropertyEditor = preload("res://addons/gloot/editor/item_property_editor.gd")
var ItemPrototypeIdEditor = preload("res://addons/gloot/editor/item_prototype_id_editor.gd")
var ItemSlotEquippedItemEditor = preload("res://addons/gloot/editor/item_slot_equipped_item_editor.gd")
var GlootUndoRedo = preload("res://addons/gloot/editor/gloot_undo_redo.gd")
var editor_interface: EditorInterface = null
var undo_redo: EditorUndoRedoManager = null :
    get:
        return undo_redo
    set(new_undo_redo):
        undo_redo = new_undo_redo
        if gloot_undo_redo:
            gloot_undo_redo.undo_redo = undo_redo
var gloot_undo_redo = null


func _init():
    gloot_undo_redo = GlootUndoRedo.new()
    gloot_undo_redo.undo_redo = undo_redo


func can_handle(object: Object) -> bool:
    return (object is Inventory) || \
            (object is InventoryItem) || \
            (object is ItemSlot) || \
            (object is ItemProtoset)


func parse_begin(object: Object) -> void:
    if object is Inventory:
        var inventory_inspector = InventoryInspector.instantiate()
        inventory_inspector.inventory = object
        inventory_inspector.editor_interface = editor_interface
        inventory_inspector.gloot_undo_redo = gloot_undo_redo
        add_custom_control(inventory_inspector)
    if object is ItemProtoset:
        var edit_protoset_button = EditProtosetButton.instantiate()
        edit_protoset_button.protoset = object
        edit_protoset_button.editor_interface = editor_interface
        edit_protoset_button.gloot_undo_redo = gloot_undo_redo
        add_custom_control(edit_protoset_button)


func parse_property(object, type, path, hint, hint_text, usage) -> bool:
    if (object is InventoryItem) && path == "properties":
        var item_property_editor =ItemPropertyEditor.new()
        item_property_editor.gloot_undo_redo = gloot_undo_redo
        item_property_editor.editor_interface = editor_interface
        add_property_editor(path, item_property_editor)
        return true
    if (object is InventoryItem) && path == "prototype_id":
        var item_prototype_id_editor =ItemPrototypeIdEditor.new()
        item_prototype_id_editor.gloot_undo_redo = gloot_undo_redo
        item_prototype_id_editor.editor_interface = editor_interface
        add_property_editor(path, item_prototype_id_editor)
        return true
    if (object is ItemSlot) && path == "equipped_item":
        var item_slot_equipped_item_editor =ItemSlotEquippedItemEditor.new()
        item_slot_equipped_item_editor.gloot_undo_redo = gloot_undo_redo
        add_property_editor(path, item_slot_equipped_item_editor)
        return true
    return false

