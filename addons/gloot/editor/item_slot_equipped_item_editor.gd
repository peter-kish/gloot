extends EditorProperty

var updating: bool = false
var _option_button: OptionButton


func _init() -> void:
    _option_button = OptionButton.new()
    add_child(_option_button)
    add_focusable(_option_button)
    _option_button.connect("item_selected", self, "_on_item_selected")


func _ready() -> void:
    var item_slot: ItemSlot = get_edited_object()
    item_slot.connect("inventory_changed", self, "_on_inventory_changed")
    _refresh_option_button()


func _on_inventory_changed(inventory: Inventory) -> void:
    _refresh_option_button()


func _refresh_option_button() -> void:
    _clear_option_button()
    _populate_option_button()


func _clear_option_button() -> void:
    _option_button.clear()
    _option_button.add_item("NONE")
    _option_button.set_item_metadata(0, -1)
    _option_button.select(0)


func _populate_option_button() -> void:
    if !get_edited_object():
        return

    var item_slot: ItemSlot = get_edited_object()
    if !item_slot.inventory:
        return

    var selected_item_index = 0
    for inventory_item_index in range(item_slot.inventory.get_items().size()):
        var item = item_slot.inventory.get_items()[inventory_item_index]
        _option_button.add_item(item.prototype_id)
        var current_item_index = _option_button.get_item_count() - 1
        _option_button.set_item_metadata(current_item_index, inventory_item_index)
        if item == item_slot.item:
            selected_item_index = current_item_index

    _option_button.select(selected_item_index)


func _on_item_selected(item_index: int) -> void:
    if !get_edited_object():
        return

    if updating:
        return

    updating = true
    var item_slot: ItemSlot = get_edited_object()
    item_slot.equipped_item = _option_button.get_item_metadata(item_index)
    updating = false
