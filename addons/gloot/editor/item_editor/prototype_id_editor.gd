@tool
extends Window

const Undoables = preload("res://addons/gloot/editor/undoables.gd")
const ChoiceFilter = preload("res://addons/gloot/editor/common/choice_filter.tscn")
const EditorIcons = preload("res://addons/gloot/editor/common/editor_icons.gd")
const POPUP_MARGIN = 10

var item: InventoryItem = null :
    set(new_item):
        if new_item == null:
            return
        assert(item == null, "Item already set!")
        item = new_item
        if item.prototree_json:
            item.prototree_json.changed.connect(_refresh)
        _refresh()


func _ready() -> void:
    about_to_popup.connect(func(): _refresh())
    close_requested.connect(func(): hide())
    %PrototreeViewer.prototype_activated.connect(_on_prototype_activated)
    hide()


func _on_prototype_activated(prototype: Prototype) -> void:
    assert(item, "Item not set!")
    if prototype != item.get_prototype():
        Undoables.exec_item_undoable(item, "Set Item Prototype", func():
            var prototype_path := str(prototype.get_path())
            item.prototype_path = prototype_path
            return item.prototype_path == prototype_path
        )
    hide()


func _refresh() -> void:
    %PrototreeViewer.prototree_json = item.prototree_json

