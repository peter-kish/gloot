extends Control

const StackManager = preload("res://addons/gloot/core/stack_manager.gd")

@onready var gloot_inventory_grid_2 = $"%GlootInventoryGrid2"
@onready var button: Button = $"%Button"


func _ready() -> void:
    button.pressed.connect(func():
        var item: InventoryItem = gloot_inventory_grid_2.get_selected_inventory_item()
        if item == null:
            return
        var stack_size: int = StackManager.get_item_stack_size(item).count
        if stack_size <= 1:
            return
        StackManager.split_stack(item, floor(float(stack_size) / 2))
    )

