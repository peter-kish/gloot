extends Control

const StacksConstraint = preload("res://addons/gloot/core/constraints/stacks_constraint.gd")

@onready var gloot_inventory_grid_2 = $"%GlootInventoryGrid2"
@onready var button: Button = $"%Button"


func _ready() -> void:
    button.pressed.connect(func():
        var item: InventoryItem = gloot_inventory_grid_2.get_selected_inventory_item()
        if item == null:
            return
        var inventory := item.get_inventory()
        var stacks_constraint = inventory.get_stacks_constraint()
        var stack_size: int = StacksConstraint.get_item_stack_size(item)
        if stack_size <= 1:
            return
        stacks_constraint.split_stack_safe(item, floor(float(stack_size) / 2))
    )

