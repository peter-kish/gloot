extends EditorInspectorPlugin

const EditProtosetButton = preload("res://addons/gloot/editor/protoset_editor/edit_protoset_button.tscn")
const InventoryInspector = preload("res://addons/gloot/editor/inventory_editor/inventory_inspector.tscn")
const EditEquippedItemButton = preload("res://addons/gloot/editor/item_slot_editor/edit_equipped_item_button.gd")


func _can_handle(object: Object) -> bool:
    return (object is Inventory) || \
            (object is InventoryItem) || \
            (object is ItemSlot) || \
            (object is ItemRefSlot) || \
            (object is ItemProtoset)


func _parse_begin(object: Object) -> void:
    if object is Inventory:
        var inventory_inspector := InventoryInspector.instantiate()
        inventory_inspector.init(object as Inventory)
        add_custom_control(inventory_inspector)
    if object is ItemSlot:
        var item_slot_inspector := ItemSlotInspector.instantiate()
        item_slot_inspector.init(object as ItemSlot)
        add_custom_control(item_slot_inspector)
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
    if (object is ItemSlot) && name == "equipped_item":
        add_property_editor(name, EditEquippedItemButton.new())
        return true
    return false

