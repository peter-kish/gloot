extends EditorProperty

var updating: bool = false
var _option_button: OptionButton
var gloot_undo_redo = null


func _init():
    _option_button = OptionButton.new()
    add_child(_option_button)
    add_focusable(_option_button)
    _option_button.item_selected.connect(Callable(self, "_on_item_selected"))


func _ready() -> void:
    var item_slot: ItemSlot = get_edited_object()
    item_slot.inventory_changed.connect(Callable(self, "_on_inventory_changed"))
    item_slot.item_set.connect(Callable(self, "_on_item_set"))
    item_slot.item_cleared.connect(Callable(self, "_on_item_cleared"))
    _refresh_option_button()


func _on_inventory_changed(inventory: Inventory) -> void:
    _refresh_option_button()


func _on_item_set(item: InventoryItem) -> void:
    _refresh_option_button()


func _on_item_cleared() -> void:
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
    for inventory_item_index in range(item_slot.inventory.get_item_count()):
        var item = item_slot.inventory.get_items()[inventory_item_index]
        _option_button.add_icon_item(item.get_texture(), item.get_title())
        var current_item_index = _option_button.get_item_count() - 1
        _option_button.set_item_metadata(current_item_index, inventory_item_index)
        if item == item_slot.item:
            selected_item_index = current_item_index

    _option_button.select(selected_item_index)


func _on_item_selected(item_index: int) -> void:
    if !get_edited_object() || updating:
        return

    updating = true
    var item_slot: ItemSlot = get_edited_object()
    var new_equipped_item = _option_button.get_item_metadata(item_index)
    if item_slot.equipped_item != new_equipped_item:
        gloot_undo_redo.set_item_slot_equipped_item(item_slot, new_equipped_item)
    updating = false

