class_name CtrlInventoryGrid
extends Container
tool

signal item_dropped

export(Vector2) var field_dimensions: Vector2 = Vector2(32, 32) setget _set_field_dimensions
export(Color) var grid_color: Color = Color.black
export(NodePath) var inventory_path: NodePath setget _set_inventory_path
export(Texture) var default_item_texture: Texture
export(int) var drag_sprite_z_index: int = 1
var inventory: InventoryGrid = null setget _set_inventory
var grabbed_ctrl_inventory_item = null
var grab_offset: Vector2
var _ctrl_inventory_item_script = preload("ctrl_inventory_item_rect.gd")
var drag_sprite: Sprite
var ctrl_item_container: Control


func _set_field_dimensions(new_field_dimensions) -> void:
    field_dimensions = new_field_dimensions
    _refresh_grid_container()


func _get_configuration_warning() -> String:
    if inventory_path.is_empty():
        return "This node is not linked to an inventory, so it can't display any content.\n" + \
               "Set the inventory_path property to point to an InventoryGrid node."
    return ""


func _set_inventory_path(new_inv_path: NodePath) -> void:
    inventory_path = new_inv_path
    var node: Node = get_node_or_null(inventory_path)

    if is_inside_tree():
        assert(node is InventoryGrid)
        
    _set_inventory(node)
    update_configuration_warning()


func _set_inventory(new_inventory: InventoryGrid) -> void:
    if new_inventory == null && inventory:
        _disconnect_signals()

    inventory = new_inventory
    _refresh()
    _connect_signals()


func _ready():
    _set_inventory(get_node_or_null(inventory_path))

    ctrl_item_container = Control.new()
    add_child(ctrl_item_container)

    drag_sprite = Sprite.new()
    drag_sprite.centered = false
    drag_sprite.z_index = drag_sprite_z_index
    drag_sprite.hide()
    add_child(drag_sprite)


func _connect_signals() -> void:
    if inventory:
        inventory.connect("contents_changed", self, "_refresh")


func _disconnect_signals() -> void:
    if inventory:
        inventory.disconnect("contents_changed", self, "_refresh")


func _refresh() -> void:
    _refresh_grid_container()
    _clear_list()
    _populate_list()


func _process(_delta):
    if drag_sprite && drag_sprite.visible:
        drag_sprite.global_position = get_global_mouse_position() - grab_offset
    update()


func _draw():
    if !inventory:
        return
    _draw_grid(Vector2.ZERO, inventory.width, inventory.height, field_dimensions)


func _draw_grid(pos: Vector2, w: int, h: int, fsize: Vector2) -> void:
    var rect = Rect2(pos, Vector2(w * fsize.x, h * fsize.y))
    draw_rect(rect, grid_color, false)
    for i in range(w):
        var from: Vector2 = Vector2(i * fsize.x, 0) + pos
        var to: Vector2 = Vector2(i * fsize.x, h * fsize.y) + pos
        draw_line(from, to, grid_color)
    for j in range(h):
        var from: Vector2 = Vector2(0, j * fsize.y) + pos
        var to: Vector2 = Vector2(w * fsize.x, j * fsize.y) + pos
        draw_line(from, to, grid_color)


func _refresh_grid_container() -> void:
    if inventory:
        rect_min_size = Vector2(inventory.width * field_dimensions.x, \
                                           inventory.height * field_dimensions.y)
        rect_size = rect_min_size


func _clear_list() -> void:
    if !ctrl_item_container:
        return

    for ctrl_inventory_item in ctrl_item_container.get_children():
        ctrl_item_container.remove_child(ctrl_inventory_item)
        ctrl_inventory_item.queue_free()


func _populate_list() -> void:
    if Engine.editor_hint:
        return

    if inventory == null:
        return

    for item in inventory.get_items():
        var ctrl_inventory_item = _ctrl_inventory_item_script.new()
        ctrl_inventory_item.ctrl_inventory = self
        ctrl_inventory_item.texture = default_item_texture
        ctrl_inventory_item.item = item
        ctrl_inventory_item.connect("grabbed", self, "_on_item_grab")
        ctrl_item_container.add_child(ctrl_inventory_item)


func _on_item_grab(ctrl_inventory_item, offset: Vector2) -> void:
    grabbed_ctrl_inventory_item = ctrl_inventory_item
    grabbed_ctrl_inventory_item.hide()
    grab_offset = offset
    if drag_sprite:
        drag_sprite.texture = ctrl_inventory_item.texture
        if drag_sprite.texture == null:
            drag_sprite.texture = default_item_texture
        var item_size = inventory.get_item_size(ctrl_inventory_item.item)
        var texture_size = drag_sprite.texture.get_size()
        drag_sprite.scale = item_size * texture_size / field_dimensions
        drag_sprite.show()


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mb_event: InputEventMouseButton = event
        if !mb_event.is_pressed() && \
            mb_event.button_index == BUTTON_LEFT && \
            grabbed_ctrl_inventory_item:

            if _is_mouse_hovering():
                var field_coords = _get_field_coords(get_global_mouse_position())
                inventory.move_item(grabbed_ctrl_inventory_item.item, \
                    field_coords.x, \
                    field_coords.y)
            else:
                emit_signal("item_dropped", grabbed_ctrl_inventory_item.item, get_global_mouse_position())
            grabbed_ctrl_inventory_item.show()
            grabbed_ctrl_inventory_item = null
            if drag_sprite:
                drag_sprite.hide()


func _is_mouse_hovering() -> bool:
    return get_global_rect().has_point(get_global_mouse_position())


func _get_field_coords(global_pos: Vector2) -> Vector2:
    var offset = global_pos - get_global_rect().position
    var x: int = offset.x / field_dimensions.x
    var y: int = offset.y / field_dimensions.y
    return Vector2(x, y)
