extends EditorInspectorPlugin

var EditProtosetButton = preload("res://addons/gloot/editor/protoset_editor/edit_protoset_button.tscn")
var InventoryInspector = preload("res://addons/gloot/editor/inventory_editor/inventory_inspector.tscn")
var EditPropertiesButton = preload("res://addons/gloot/editor/item_editor/edit_properties_button.gd")
var EditPrototypeIdButton = preload("res://addons/gloot/editor/item_editor/edit_prototype_id_button.gd")
var EditEquippedItemButton = preload("res://addons/gloot/editor/item_slot_editor/edit_equipped_item_button.gd")
var GlootUndoRedo = preload("res://addons/gloot/editor/gloot_undo_redo.gd")
var editor_interface: EditorInterface = null
var undo_redo_manager: EditorUndoRedoManager = null :
    get:
        return undo_redo_manager
    set(new_undo_redo):
        undo_redo_manager = new_undo_redo
        if gloot_undo_redo:
            gloot_undo_redo.undo_redo_manager = undo_redo_manager
var gloot_undo_redo = null


func _init():
    gloot_undo_redo = GlootUndoRedo.new()
    gloot_undo_redo.undo_redo_manager = undo_redo_manager


func _can_handle(object: Object) -> bool:
    return (object is Inventory) || \
            (object is InventoryItem) || \
            (object is ItemSlot) || \
            (object is ItemProtoset)


func _parse_begin(object: Object) -> void:
    if object is Inventory:
        var inventory_inspector := InventoryInspector.instantiate()
        inventory_inspector.init(object as Inventory, gloot_undo_redo, editor_interface)
        add_custom_control(inventory_inspector)
    if object is ItemProtoset:
        var edit_protoset_button := EditProtosetButton.instantiate()
        edit_protoset_button.init(object as ItemProtoset, gloot_undo_redo, editor_interface)
        add_custom_control(edit_protoset_button)


func _parse_property(object: Object,
        type: Variant.Type,
        name: String,
        hint: PropertyHint,
        hint_string: String,
        usage: int,
        wide: bool) -> bool:
    if (object is InventoryItem) && name == "properties":
        var item_property_editor = EditPropertiesButton.new(gloot_undo_redo, editor_interface)
        add_property_editor(name, item_property_editor)
        return true
    if (object is InventoryItem) && name == "prototype_id":
        var item_prototype_id_editor = EditPrototypeIdButton.new(gloot_undo_redo, editor_interface)
        add_property_editor(name, item_prototype_id_editor)
        return true
    if (object is ItemSlot) && name == "equipped_item":
        var item_slot_equipped_item_editor = EditEquippedItemButton.new()
        item_slot_equipped_item_editor.gloot_undo_redo = gloot_undo_redo
        add_property_editor(name, item_slot_equipped_item_editor)
        return true
    return false

