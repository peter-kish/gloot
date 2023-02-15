@tool
extends Control

const InventoryEditor = preload("res://addons/gloot/editor/inventory_editor.tscn")
const EditorIcons = preload("res://addons/gloot/editor/editor_icons.gd")
const POPUP_SIZE = Vector2(800, 600)
const POPUP_MIN_SIZE = Vector2(400, 300)
const POPUP_MARGIN = 10

@onready var inventory_editor: Control = $HBoxContainer/InventoryEditor
@onready var btn_expand: Button = $HBoxContainer/BtnExpand

var inventory: Inventory :
    get:
        return inventory
    set(new_inventory):
        inventory = new_inventory
        if inventory_editor:
            inventory_editor.inventory = inventory
var editor_interface: EditorInterface :
    get:
        return editor_interface
    set(new_editor_interface):
        editor_interface = new_editor_interface
        if inventory_editor:
            inventory_editor.editor_interface = editor_interface
var gloot_undo_redo :
    get:
        return gloot_undo_redo
    set(new_gloot_undo_redo):
        gloot_undo_redo = new_gloot_undo_redo
        if inventory_editor:
            inventory_editor.gloot_undo_redo = gloot_undo_redo
var _window_dialog: Window
var _popup_inventory_editor: Control


func _init():
    _window_dialog = Window.new()
    _window_dialog.title = "Edit Inventory"
    _window_dialog.unresizable = false
    _window_dialog.size = POPUP_SIZE
    _window_dialog.min_size = POPUP_MIN_SIZE
    _window_dialog.visible = false
    _window_dialog.exclusive = true
    _window_dialog.close_requested.connect(func(): _window_dialog.hide())
    add_child(_window_dialog)

    _popup_inventory_editor = InventoryEditor.instantiate()

    var _margin_container = MarginContainer.new()
    _margin_container.offset_bottom = -POPUP_MARGIN
    _margin_container.offset_left = POPUP_MARGIN
    _margin_container.offset_right = -POPUP_MARGIN
    _margin_container.offset_top = POPUP_MARGIN
    _margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _margin_container.size_flags_vertical = SIZE_EXPAND_FILL
    _margin_container.anchor_bottom = 1.0
    _margin_container.anchor_right = 1.0
    _margin_container.add_child(_popup_inventory_editor)
    _window_dialog.add_child(_margin_container)


func _ready() -> void:
    if inventory_editor:
        inventory_editor.inventory = inventory
        inventory_editor.editor_interface = editor_interface
        inventory_editor.gloot_undo_redo = gloot_undo_redo
    _apply_editor_settings()
    btn_expand.icon = EditorIcons.get_icon(editor_interface, "DistractionFree")
    btn_expand.connect("pressed", Callable(self, "on_btn_expand"))


func on_btn_expand() -> void:
    _popup_inventory_editor.inventory = inventory
    _popup_inventory_editor.gloot_undo_redo = gloot_undo_redo
    _popup_inventory_editor.editor_interface = editor_interface
    _window_dialog.popup_centered(POPUP_SIZE)


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    custom_minimum_size.y = control_height
