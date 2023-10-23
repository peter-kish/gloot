@tool
extends TextureRect

var item: InventoryItem = null


func _get_drag_data(at_position: Vector2):
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_drag_preview(_get_drag_preview())
    return self


func _get_drag_preview() -> Control:
    var preview = TextureRect.new()
    preview.texture = texture
    preview.size = size
    return preview


func _notification(what) -> void:
    if what == NOTIFICATION_DRAG_END:
        _on_drag_end()
    elif what == NOTIFICATION_DRAG_BEGIN:
        var drag_data = get_viewport().gui_get_drag_data()
        if drag_data == null:
            return
        if drag_data.item == item:
            _on_drag_start()


func _on_drag_start() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    modulate = Color(1.0, 1.0, 1.0, 0.5)


func _on_drag_end() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    modulate = Color.WHITE

