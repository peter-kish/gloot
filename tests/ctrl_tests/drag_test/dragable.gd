@tool
extends "res://addons/gloot/ui/ctrl_dragable.gd"

@export var texture: Texture2D :
    get:
        return texture
    set(new_texture):
        if texture == new_texture:
            return
        texture = new_texture
        if _texture_rect:
            _texture_rect.texture = texture

var _texture_rect: TextureRect
var _preview: TextureRect


func _ready() -> void:
    _texture_rect = TextureRect.new()
    _texture_rect.texture = texture
    _texture_rect.resized.connect(func(): size = _texture_rect.size)
    add_child(_texture_rect)


func drag_start() -> void:
    if _texture_rect:
        _texture_rect.hide()

    if _preview == null:
        _preview = TextureRect.new()
        if _preview is Control:
            _preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _preview.texture = texture
        add_child(_preview)
        _preview.global_position = get_global_mouse_position() - get_grab_offset()


func drag_end() -> void:
    if _texture_rect:
        _texture_rect.show()

    if _preview:
        remove_child(_preview)
        _preview.queue_free()
        _preview = null


func _process(_delta) -> void:
    if _preview:
        _preview.global_position = get_global_mouse_position() - get_grab_offset()
