@tool
extends "res://addons/gloot/ui/ctrl_dragable.gd"

@export var texture: Texture2D:
    set(new_texture):
        if texture == new_texture:
            return
        texture = new_texture
        if _texture_rect:
            _texture_rect.texture = texture

var _texture_rect: TextureRect


func _ready() -> void:
    _texture_rect = TextureRect.new()
    _texture_rect.texture = texture
    _texture_rect.resized.connect(func(): size = _texture_rect.size)
    add_child(_texture_rect)
    grabbed.connect(func(_offset):
        _on_dragable_grabbed()
    )


func _on_dragable_grabbed() -> void:
    if _texture_rect:
        _texture_rect.hide()


func _notification(what) -> void:
    if what == NOTIFICATION_DRAG_END:
        if _texture_rect:
            _texture_rect.show()


func create_preview() -> Control:
    var preview = TextureRect.new()
    preview.texture = texture
    preview.scale = get_global_transform().get_scale()
    return preview
