extends Control
tool

onready var prototype_filter = $TabContainer/Gui/PrototypeFilter
onready var prototype_editor = $TabContainer/Gui/DictEditor

var protoset: ItemProtoset setget _set_protoset


func _set_protoset(new_protoset: ItemProtoset) -> void:
    protoset = new_protoset
    _refresh()


func _ready() -> void:
    prototype_filter.connect("choice_selected", self, "_on_prototype_selected")
    _refresh()


func _refresh() -> void:
    _clear()
    _populate()


func _clear() -> void:
    prototype_filter.values.clear()
    prototype_editor.dictionary.clear()


func _populate() -> void:
    if protoset:
        # TODO: Avoid accessing "private" members (_prototypes)
        prototype_filter.values = protoset._prototypes.keys().duplicate()


func _on_prototype_selected(index: int) -> void:
    var prototype_id: String = prototype_filter.values[index]
    # TODO: Avoid accessing "private" members (_prototypes)
    prototype_editor.dictionary = protoset._prototypes[prototype_id]
