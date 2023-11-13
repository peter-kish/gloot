extends EditorInspectorPlugin

const EditProtosetButton = preload("res://addons/gloot/editor/protoset_editor/edit_protoset_button.tscn")
const InventoryInspector = preload("res://addons/gloot/editor/inventory_editor/inventory_inspector.tscn")
const EditPropertiesButton = preload("res://addons/gloot/editor/item_editor/edit_properties_button.gd")
const EditPrototypeIdButton = preload("res://addons/gloot/editor/item_editor/edit_prototype_id_button.gd")
const EditEquippedItemButton = preload("res://addons/gloot/editor/item_slot_editor/edit_equipped_item_button.gd")


func _can_handle(object: Object) -> bool:
    return (object is Inventory) || \
            (object is InventoryItem) || \
            (object is ItemSlot) || \
            (object is ItemProtoset)


func _parse_begin(object: Object) -> void:
    if object is Inventory:
        var inventory_inspector := InventoryInspector.instantiate()
        inventory_inspector.init(object as Inventory)
        add_custom_control(inventory_inspector)
    if object is ItemProtoset:
        var edit_protoset_button := EditProtosetButton.instantiate()
        edit_protoset_button.init(object as ItemProtoset)
        add_custom_control(edit_protoset_button)


func _parse_property(object: Object,
        type: Variant.Type,
        name: String,
        hint: PropertyHint,
        hint_string: String,
        usage: int,
        wide: bool) -> bool:
    if (object is InventoryItem) && name == "properties":
        add_property_editor(name, EditPropertiesButton.new())
        return true
    if (object is InventoryItem) && name == "prototype_id":
        add_property_editor(name, EditPrototypeIdButton.new())
        return true
    if (object is ItemSlot) && name == "equipped_item":
        add_property_editor(name, EditEquippedItemButton.new())
        return true
    return false

