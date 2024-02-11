@tool
extends "res://addons/gloot/ui/ctrl_dragable.gd"

@export var texture: Texture2D :
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

    drag_preview = TextureRect.new()
    drag_preview.texture = texture


func drag_start() -> void:
    super.drag_start()
    if _texture_rect:
        _texture_rect.hide()


func drag_end() -> void:
    super.drag_end()
    if _texture_rect:
        _texture_rect.show()

