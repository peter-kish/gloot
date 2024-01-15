extends EditorProperty

const GlootUndoRedo = preload("res://addons/gloot/editor/gloot_undo_redo.gd")

var updating: bool = false
var _option_button: OptionButton


func _init():
    _option_button = OptionButton.new()
    add_child(_option_button)
    add_focusable(_option_button)
    _option_button.item_selected.connect(_on_item_selected)


func _ready() -> void:
    var item_ref_slot: ItemRefSlot = get_edited_object()
    item_ref_slot.inventory_changed.connect(_refresh_option_button)
    item_ref_slot.item_equipped.connect(_refresh_option_button)
    item_ref_slot.cleared.connect(_refresh_option_button)
    _refresh_option_button()


func _refresh_option_button() -> void:
    _clear_option_button()
    _populate_option_button()


func _clear_option_button() -> void:
    _option_button.clear()
    _option_button.add_item("None")
    _option_button.set_item_metadata(0, null)
    _option_button.select(0)


func _populate_option_button() -> void:
    if !get_edited_object():
        return

    var item_ref_slot: ItemRefSlot = get_edited_object()
    if !item_ref_slot.inventory:
        return

    var equipped_item_index := 0
    for item in item_ref_slot.inventory.get_items():
        _option_button.add_icon_item(item.get_texture(), item.get_title())
        var option_item_index = _option_button.get_item_count() - 1
        _option_button.set_item_metadata(option_item_index, item)
        if item == item_ref_slot.get_item():
            equipped_item_index = option_item_index

    _option_button.select(equipped_item_index)


func _on_item_selected(item_index: int) -> void:
    if !get_edited_object() || updating:
        return

    updating = true
    var item_ref_slot: ItemRefSlot = get_edited_object()
    var selected_item: InventoryItem = _option_button.get_item_metadata(item_index)
    if item_ref_slot.get_item() != selected_item:
        if selected_item == null:
            GlootUndoRedo.clear_item_slot(item_ref_slot)
        else:
            GlootUndoRedo.equip_item_in_item_slot(item_ref_slot, selected_item)
    updating = false
