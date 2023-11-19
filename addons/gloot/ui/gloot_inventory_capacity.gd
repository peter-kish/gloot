@tool
class_name  GlootInventoryCapacity
extends Control

const GLootCapacityBar = preload("res://addons/gloot/ui/gloot_inventory_capacity_bar.gd")
const GLootCapacityLabel = preload("res://addons/gloot/ui/gloot_inventory_capacity_label.gd")

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        inventory = get_node_or_null(inventory_path)

@export var background_style: StyleBox :
    get:
        return background_style
    set(new_background_style):
        background_style = new_background_style
        if _capacity_bar != null:
            _capacity_bar.background_style = new_background_style
        
@export var bar_style: StyleBox :
    get:
        return bar_style
    set(new_bar_style):
        bar_style = new_bar_style
        if _capacity_bar != null:
            _capacity_bar.bar_style = new_bar_style

@export var font: Font : 
    get:
        return font
    set(new_font):
        if new_font == font:
            return
        font = new_font
        _set_label_font(_capacity_label, font)

@export var font_size: int : 
    get:
        return font_size
    set(new_font_size):
        if new_font_size == font_size || new_font_size <= 0:
            return
        font_size = new_font_size
        _set_label_font_size(_capacity_label, font_size)

@export var font_outline_size: int : 
    get:
        return font_outline_size
    set(new_font_outline_size):
        if new_font_outline_size == font_outline_size || new_font_outline_size < 0:
            return
        font_outline_size = new_font_outline_size
        _set_label_font_outline_size(_capacity_label, font_outline_size)

@export var font_color: Color : 
    get:
        return font_color
    set(new_font_color):
        if new_font_color == font_color:
            return
        font_color = new_font_color
        _set_label_font_color(_capacity_label, font_color)

@export var font_outline_color: Color : 
    get:
        return font_outline_color
    set(new_font_outline_color):
        if new_font_outline_color == font_outline_color:
            return
        font_outline_color = new_font_outline_color
        _set_label_font_outline_color(_capacity_label, font_outline_color)

var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        if inventory == new_inventory:
            return

        inventory = new_inventory
        if _capacity_bar != null:
            _capacity_bar.inventory = inventory
        if _capacity_label != null:
            _capacity_label.inventory = inventory

var _capacity_bar: GLootCapacityBar
var _capacity_label: GLootCapacityLabel


func _ready() -> void:
    if !inventory_path.is_empty():
        inventory = get_node_or_null(inventory_path)

    _capacity_bar = GLootCapacityBar.new()
    _capacity_bar.inventory = inventory
    _capacity_bar.background_style = background_style
    _capacity_bar.bar_style = bar_style
    add_child(_capacity_bar)

    _capacity_label = GLootCapacityLabel.new()
    _capacity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _capacity_label.inventory = inventory
    _set_label_font(_capacity_label, font)
    _set_label_font_size(_capacity_label, font_size)
    _set_label_font_outline_size(_capacity_label, font_outline_size)
    _set_label_font_color(_capacity_label, font_color)
    _set_label_font_outline_color(_capacity_label, font_outline_color)
    add_child(_capacity_label)

    custom_minimum_size.y = _capacity_label.size.y
    size.y = _capacity_label.size.y
    _capacity_label.size.x = size.x
    _capacity_bar.size = size
    _capacity_label.resized.connect(func():
        custom_minimum_size.y = _capacity_label.size.y
        size.y = _capacity_label.size.y
    )
    resized.connect(func():
        _capacity_bar.size = size
        _capacity_label.size.x = size.x
    )


func _set_label_font(label: Label, font: Font) -> void:
    if label == null:
        return
    label.remove_theme_font_override("font")
    if font != null:
        label.add_theme_font_override("font", font)
    # Reset vertical label size
    label.size.y = 0


func _set_label_font_size(label: Label, font_size: int) -> void:
    if label == null:
        return
    label.remove_theme_font_size_override("font_size")
    label.add_theme_font_size_override("font_size", font_size)
    # Reset vertical label size
    label.size.y = 0


func _set_label_font_outline_size(label: Label, font_outline_size: int) -> void:
    if label == null:
        return
    label.remove_theme_constant_override("outline_size")
    label.add_theme_constant_override("outline_size", font_outline_size)
    # Reset vertical label size
    label.size.y = 0


func _set_label_font_color(label, font_color) -> void:
    if label == null:
        return
    label.remove_theme_color_override("font_color")
    label.add_theme_color_override("font_color", font_color)


func _set_label_font_outline_color(label, font_outline_color) -> void:
    if label == null:
        return
    label.remove_theme_color_override("font_outline_color")
    label.add_theme_color_override("font_outline_color", font_color)