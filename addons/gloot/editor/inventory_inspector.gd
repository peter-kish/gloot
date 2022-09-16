extends Control
tool

const InventoryEditor = preload("res://addons/gloot/editor/inventory_editor.tscn")
const EditorIcons = preload("res://addons/gloot/editor/editor_icons.gd")
const POPUP_SIZE = Vector2(800, 600)
const POPUP_MIN_SIZE = Vector2(400, 300)
const POPUP_MARGIN = 10

onready var inventory_editor: Control = $HBoxContainer/InventoryEditor
onready var btn_expand: Button = $HBoxContainer/BtnExpand

var inventory: Inventory setget _set_inventory
var editor_interface: EditorInterface setget _set_editor_interface
var gloot_undo_redo setget _set_undo_redo
var _window_dialog: WindowDialog
var _popup_inventory_editor: Control


func _set_inventory(new_inventory: Inventory) -> void:
    inventory = new_inventory
    if inventory_editor:
        inventory_editor.inventory = inventory


func _set_editor_interface(new_editor_interface: EditorInterface) -> void:
    editor_interface = new_editor_interface
    if inventory_editor:
        inventory_editor.editor_interface = editor_interface


func _set_undo_redo(new_gloot_undo_redo) -> void:
    gloot_undo_redo = new_gloot_undo_redo
    if inventory_editor:
        inventory_editor.gloot_undo_redo = gloot_undo_redo


func _init() -> void:
    _window_dialog = WindowDialog.new()
    _window_dialog.window_title = "Edit Inventory"
    _window_dialog.resizable = true
    _window_dialog.rect_size = POPUP_SIZE
    _window_dialog.rect_min_size = POPUP_MIN_SIZE
    add_child(_window_dialog)

    _popup_inventory_editor = InventoryEditor.instance()

    var _margin_container = MarginContainer.new()
    _margin_container.margin_bottom = -POPUP_MARGIN
    _margin_container.margin_left = POPUP_MARGIN
    _margin_container.margin_right = -POPUP_MARGIN
    _margin_container.margin_top = POPUP_MARGIN
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
    btn_expand.connect("pressed", self, "on_btn_expand")


func on_btn_expand() -> void:
    _popup_inventory_editor.inventory = inventory
    _popup_inventory_editor.gloot_undo_redo = gloot_undo_redo
    _popup_inventory_editor.editor_interface = editor_interface
    _window_dialog.popup_centered(POPUP_SIZE)


func _apply_editor_settings() -> void:
    var control_height: int = ProjectSettings.get_setting("gloot/inspector_control_height")
    rect_min_size.y = control_height