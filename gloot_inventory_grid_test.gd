extends Control


@onready var gloot_inventory_grid_2 = $"%GlootInventoryGrid2"
@onready var button: Button = $"%Button"


func _ready() -> void:
    button.pressed.connect(func():
        var item: InventoryItem = gloot_inventory_grid_2.get_selected_item()
        if item == null:
            return
        var inventory := item.get_inventory()
        var stacks_constraint = inventory._constraint_manager.get_stacks_constraint()
        var stack_size: int = stacks_constraint.get_item_stack_size(item)
        if stack_size <= 1:
            return
        stacks_constraint.split_stack_safe(item, stack_size / 2)
    )

