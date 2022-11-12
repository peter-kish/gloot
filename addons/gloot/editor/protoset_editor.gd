extends Control
tool

onready var prototype_filter = $"%PrototypeFilter"
onready var property_editor = $"%PropertyEditor"
onready var txt_prototype_id = $"%TxtPrototypeName"
onready var btn_add_prototype = $"%BtnAddPrototype"
onready var btn_remove_prototype = $"%BtnRemovePrototype"

var protoset: ItemProtoset setget _set_protoset


func _set_protoset(new_protoset: ItemProtoset) -> void:
    protoset = new_protoset
    _refresh()


func _ready() -> void:
    prototype_filter.connect("choice_selected", self, "_on_prototype_selected")
    txt_prototype_id.connect("text_changed", self, "_on_prototype_id_changed")
    txt_prototype_id.connect("text_entered", self, "_on_prototype_id_entered")
    btn_add_prototype.connect("pressed", self, "_on_btn_add_prototype")
    btn_remove_prototype.connect("pressed", self, "_on_btn_remove_prototype")
    _refresh()


func _refresh() -> void:
    _clear()
    _populate()
    _refresh_btn_add_prototype()


func _clear() -> void:
    prototype_filter.values.clear()
    property_editor.dictionary.clear()
    property_editor.refresh()


func _populate() -> void:
    if protoset:
        # TODO: Avoid accessing "private" members (_prototypes)
        prototype_filter.values = protoset._prototypes.keys().duplicate()


func _refresh_btn_add_prototype() -> void:
    btn_add_prototype.disabled = txt_prototype_id.text.empty() ||\
        protoset.has(txt_prototype_id.text)


func _on_prototype_selected(index: int) -> void:
    var prototype_id: String = prototype_filter.values[index]
    property_editor.dictionary = protoset.get(prototype_id)
    property_editor.immutable_keys = [ItemProtoset.KEY_ID]
    property_editor.remove_button_map = {
        ItemProtoset.KEY_ID: {
            "text": "Remove",
            "disabled": true,
            "icon": null,
        }
    }


func _on_prototype_id_changed(new_prototype_id_: String) -> void:
    _refresh_btn_add_prototype()


func _on_prototype_id_entered(prototype_id: String) -> void:
    _add_prototype_id(prototype_id)


func _on_btn_add_prototype() -> void:
    _add_prototype_id(txt_prototype_id.text)


func _add_prototype_id(prototype_id: String) -> void:
    protoset.add(prototype_id)
    txt_prototype_id.text = ""
    _refresh()


func _on_btn_remove_prototype() -> void:
    var prototype_id = prototype_filter.get_selected_text()
    if !prototype_id.empty():
        protoset.remove(prototype_id)
        _refresh()
