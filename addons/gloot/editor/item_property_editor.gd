extends EditorProperty

const DictEditor = preload("res://addons/gloot/editor/dict_editor.tscn")
const COLOR_OVERRIDDEN = Color.green
var _dict_editor: Control
var current_value: Dictionary
var updating: bool = false
var gloot_undo_redo = null


func _init() -> void:
    rect_min_size.y = 200

    _dict_editor = DictEditor.instance()
    add_child(_dict_editor)
    add_focusable(_dict_editor)
    set_bottom_editor(_dict_editor)
    _refresh_dict_editor()
    _dict_editor.connect("value_changed", self, "_on_value_changed")


func _ready() -> void:
    var item: InventoryItem = get_edited_object()
    if item:
        item.connect("properties_changed", self, "update_property")


func _on_value_changed(key: String, new_value) -> void:
    var item: InventoryItem = get_edited_object()
    var new_properties = item.properties.duplicate()
    new_properties[key] = new_value

    var item_prototype: Dictionary = item.protoset.get(item.prototype_id)
    if item_prototype.has(key) && (item_prototype[key] == new_value):
        new_properties.erase(key)

    if new_properties.hash() == item.properties.hash():
        return

    gloot_undo_redo.set_item_properties(item, new_properties)

    _refresh_dict_editor()


func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if new_value == current_value:
        return

    updating = true
    current_value = new_value
    _refresh_dict_editor()
    updating = false


func _refresh_dict_editor() -> void:
    _dict_editor.dictionary = _get_dictionary()
    _dict_editor.color_map = _get_color_map()
    _dict_editor.refresh()


func _get_dictionary() -> Dictionary:
    if !get_edited_object():
        return {}

    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return {}

    if !item.protoset.has(item.prototype_id):
        return {}

    var result: Dictionary = item.protoset.get(item.prototype_id).duplicate()
    for key in item.properties.keys():
        result[key] = item.properties[key]
    return result


func _get_color_map() -> Dictionary:
    if !get_edited_object():
        return {}

    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return {}

    var result: Dictionary = {}
    var dictionary: Dictionary = _get_dictionary()
    for key in dictionary.keys():
        if item.properties.has(key):
            result[key] = COLOR_OVERRIDDEN

    return result
            
