tool
extends Control

onready var item_list_prototypes = $VBoxContainer/HBoxContainer/PrototypesContainer/ItemList
onready var edt_filter_prototypes = $VBoxContainer/HBoxContainer/PrototypesContainer/HBoxContainer/LineEdit
onready var item_list_items = $VBoxContainer/HBoxContainer/ItemsContainer/ItemList
onready var edt_filter_items = $VBoxContainer/HBoxContainer/ItemsContainer/HBoxContainer/LineEdit
onready var btn_add = $VBoxContainer/HBoxContainer/PrototypesContainer/BtnAdd
onready var btn_remove = $VBoxContainer/HBoxContainer/ItemsContainer/BtnRemove
onready var space_container = $VBoxContainer/HBoxContainer/ItemsContainer/MarginContainer
onready var progress_bar = $VBoxContainer/HBoxContainer/ItemsContainer/MarginContainer/ProgressBar
onready var lbl_space = $VBoxContainer/HBoxContainer/ItemsContainer/MarginContainer/Label

var inventory: Inventory
var editor_interface: EditorInterface = null


func _ready():
    btn_add.connect("pressed", self, "_on_btn_add")
    btn_remove.connect("pressed", self, "_on_btn_remove")
    item_list_prototypes.connect("item_activated", self, "_on_prototype_activated")
    item_list_items.connect("item_activated", self, "_on_item_activated")
    edt_filter_prototypes.connect("text_changed", self, "_on_properties_filter_changed")
    edt_filter_items.connect("text_changed", self, "_on_items_filter_changed")

    if editor_interface:
        btn_add.icon = editor_interface.get_base_control().get_icon("Add", "EditorIcons")
        btn_remove.icon = editor_interface.get_base_control().get_icon("Remove", "EditorIcons")

    if inventory:
        if inventory is InventoryStacked:
            inventory.connect("capacity_changed", self, "_refresh")
            inventory.connect("protoset_changed", self, "_refresh")
        edit(inventory)


func _on_prototype_activated(index: int) -> void:
    if inventory == null || inventory.item_protoset == null:
        return
    inventory.contents.append(_get_prototype(index))
    _refresh()


func _on_item_activated(index: int) -> void:
    if inventory == null || inventory.item_protoset == null:
        return
    inventory.contents.remove(index)
    _refresh()


func _on_properties_filter_changed(new_text: String) -> void:
    if inventory == null || inventory.item_protoset == null:
        return

    item_list_prototypes.clear()
    for prototype_id in inventory.item_protoset._prototypes.keys():
        if !new_text.empty() && !(new_text in prototype_id):
            continue
        _add_prototype(prototype_id)


func _on_items_filter_changed(new_text: String) -> void:
    if inventory == null || inventory.item_protoset == null:
        return

    item_list_items.clear()
    for prototype_id in inventory.contents:
        if !new_text.empty() && !(new_text in prototype_id):
            continue
        _add_item(prototype_id)


func _add_prototype(prototype_id: String) -> void:
    item_list_prototypes.add_item(_get_prototype_description(prototype_id), \
        _get_prototype_icon(prototype_id))
    item_list_prototypes.set_item_metadata(item_list_prototypes.get_item_count() - 1, prototype_id)


func _add_item(prototype_id: String) -> void:
    item_list_items.add_item(_get_prototype_description(prototype_id), \
        _get_prototype_icon(prototype_id))
    item_list_items.set_item_metadata(item_list_items.get_item_count() - 1, prototype_id)
    
    
func _get_prototype(index: int) -> String:
    return item_list_prototypes.get_item_metadata(index)


func _get_prototype_description(prototype_id: String) -> String:
    if inventory == null || inventory.item_protoset == null:
        return ""

    var stack_size = inventory.item_protoset.get_item_property(prototype_id, InventoryStacked.KEY_STACK_SIZE, 1);
    if stack_size == 1:
        return prototype_id
    else:
        return "%s (x%d)" % [prototype_id, stack_size]


func _on_btn_add() -> void:
    if inventory == null || inventory.item_protoset == null:
        return

    for i in item_list_prototypes.get_selected_items():
        inventory.contents.append(item_list_prototypes.get_item_metadata(i))
        item_list_prototypes.unselect(i)
    _refresh()


func _on_btn_remove() -> void:
    if inventory == null || inventory.item_protoset == null:
        return

    var selected_items: PoolIntArray = item_list_items.get_selected_items()
    for i in range(selected_items.size() - 1, -1, -1):
        inventory.contents.remove(selected_items[i])
    _refresh()


func edit(inv: Inventory) -> void:
    reset()
    inventory = inv
    if inventory == null || inventory.item_protoset == null:
        return

    for prototype_id in inventory.contents:
        _add_item(prototype_id)
    for prototype_id in inventory.item_protoset._prototypes.keys():
        _add_prototype(prototype_id)

    var show_space: bool = (inventory is InventoryStacked) && !inventory.has_unlimited_capacity()
    space_container.visible = show_space
    if show_space:
        var occupied_space: float = _get_occupied_space()
        lbl_space.text = "%d/%d" % [occupied_space, inventory.capacity]
        if occupied_space > inventory.capacity:
            lbl_space.add_color_override("font_color", Color.red)
        else:
            lbl_space.add_color_override("font_color", Color.white)
        progress_bar.value = 100.0 * (occupied_space / inventory.capacity)


func _get_occupied_space() -> float:
    if inventory == null || inventory.item_protoset == null:
        return -1.0

    var result: float = 0
    for prototype_id in inventory.contents:
        if !inventory.item_protoset:
            continue
        var unit_weight: float = inventory.item_protoset.get_item_property(prototype_id, InventoryStacked.KEY_WEIGHT, 1.0)
        var stack_size: int = inventory.item_protoset.get_item_property(prototype_id, InventoryStacked.KEY_STACK_SIZE, 1)
        result += unit_weight * stack_size
    return result


func _get_prototype_icon(prototype_id: String) -> Texture:
    if inventory == null || inventory.item_protoset == null:
        return null

    var texture_path = inventory.item_protoset.get_item_property(prototype_id, CtrlInventory.KEY_IMAGE)
    if texture_path:
        var resource = load(texture_path)
        if resource is Texture:
            return resource
    return null


func reset() -> void:
    item_list_items.clear()
    item_list_prototypes.clear()
    edt_filter_prototypes.text = ""
    edt_filter_items.text = ""
    inventory = null
    space_container.hide()


func _refresh() -> void:
    var inv = inventory
    reset()
    edit(inv)