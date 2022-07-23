extends EditorProperty


const ChoiceFilter = preload("res://addons/gloot/editor/choice_filter.tscn")
var current_value: String
var updating: bool = false
var _choice_filter: Control
var _popup_panel: PopupPanel
var _btn_prototype_id: Button


func _init() -> void:
    _choice_filter = ChoiceFilter.instance()
    _choice_filter.pick_text = "Select"
    _choice_filter.connect("choice_picked", self, "_on_choice_picked")

    _popup_panel = PopupPanel.new()
    _popup_panel.add_child(_choice_filter)
    _popup_panel.rect_size = Vector2(200, 200)
    add_child(_popup_panel)

    _btn_prototype_id = Button.new()
    _btn_prototype_id.text = "Prototype ID"
    _btn_prototype_id.connect("pressed", self, "_on_btn_prototype_id")
    add_child(_btn_prototype_id)


func _ready() -> void:
    var item: InventoryItem = get_edited_object()
    _btn_prototype_id.text = item.prototype_id


func _on_btn_prototype_id() -> void:
    _popup_panel.popup_centered()


func _on_choice_picked(value_index: int) -> void:
    var item: InventoryItem = get_edited_object()
    item.prototype_id = _choice_filter.values[value_index]
    _popup_panel.hide()


func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if new_value == current_value:
        return

    updating = true
    current_value = new_value
    _refresh_choice_filter()
    updating = false


func _refresh_choice_filter() -> void:
    _choice_filter.values = _get_prototype_ids()
    _choice_filter.refresh()


func _get_prototype_ids() -> Array:
    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return []

    return item.protoset._prototypes.keys()
