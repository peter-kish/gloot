@tool
extends Control

@export var inventory: Inventory :
    set(new_inventory):
        if new_inventory == inventory:
            return
        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()
        _refresh()


func _connect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return

    inventory.constraint_enabled.connect(_on_constraint_enabled)
    inventory.constraint_disabled.connect(_on_constraint_disabled)
    inventory.pre_constraint_disabled.connect(_on_pre_constraint_disabled)


func _disconnect_inventory_signals() -> void:
    if !is_instance_valid(inventory):
        return

    inventory.constraint_enabled.disconnect(_on_constraint_enabled)
    inventory.constraint_disabled.disconnect(_on_constraint_disabled)
    inventory.pre_constraint_disabled.disconnect(_on_pre_constraint_disabled)


func _on_constraint_enabled(constraint: int) -> void:
    if constraint == Inventory.Constraint.WEIGHT:
        if !%CheckBoxWeightConstraint.button_pressed:
            %CheckBoxWeightConstraint.button_pressed = true
        %LineEditCapacity.editable = true
        %LineEditCapacity.text = str(inventory.get_weight_constraint().capacity)
        inventory.get_weight_constraint().capacity_changed.connect(_on_capacity_changed)
    elif constraint == Inventory.Constraint.STACKS:
        if !%CheckBoxStacksConstraint.button_pressed:
            %CheckBoxStacksConstraint.button_pressed = true
    elif constraint == Inventory.Constraint.GRID:
        if !%CheckBoxGridConstraint.button_pressed:
            %CheckBoxGridConstraint.button_pressed = true
        %LineEditSizeX.editable = true
        %LineEditSizeX.text = str(inventory.get_grid_constraint().size.x)
        %LineEditSizeY.editable = true
        %LineEditSizeY.text = str(inventory.get_grid_constraint().size.y)
        inventory.get_grid_constraint().size_changed.connect(_on_size_changed)


func _on_constraint_disabled(constraint: int) -> void:
    if constraint == Inventory.Constraint.WEIGHT:
        if %CheckBoxWeightConstraint.button_pressed:
            %CheckBoxWeightConstraint.button_pressed = false
        %LineEditCapacity.editable = false
        %LineEditCapacity.text = ""
    elif constraint == Inventory.Constraint.STACKS:
        if %CheckBoxStacksConstraint.button_pressed:
            %CheckBoxStacksConstraint.button_pressed = false
    elif constraint == Inventory.Constraint.GRID:
        if %CheckBoxGridConstraint.button_pressed:
            %CheckBoxGridConstraint.button_pressed = false
        %LineEditSizeX.editable = false
        %LineEditSizeX.text = ""
        %LineEditSizeY.editable = false
        %LineEditSizeY.text = ""


func _on_pre_constraint_disabled(constraint: int) -> void:
    if constraint == Inventory.Constraint.WEIGHT:
        inventory.get_weight_constraint().capacity_changed.disconnect(_on_capacity_changed)
    elif constraint == Inventory.Constraint.GRID:
        inventory.get_grid_constraint().size_changed.disconnect(_on_size_changed)


func _on_capacity_changed() -> void:
    var str_capacity := str(inventory.get_weight_constraint().capacity)
    if %LineEditCapacity.text != str_capacity:
        %LineEditCapacity.text = str_capacity


func _on_size_changed() -> void:
    var str_size_x := str(inventory.get_grid_constraint().size.x)
    var str_size_y := str(inventory.get_grid_constraint().size.y)
    if %LineEditSizeX.text != str_size_x:
        %LineEditSizeX.text = str_size_x
    if %LineEditSizeY.text != str_size_y:
        %LineEditSizeY.text = str_size_y


func _ready() -> void:
    _refresh()

    %CheckBoxWeightConstraint.toggled.connect(func(toggled_on: bool):
        if toggled_on:
            if !is_instance_valid(inventory.get_weight_constraint()):
                inventory.enable_weight_constraint()
        else:
            if is_instance_valid(inventory.get_weight_constraint()):
                inventory.disable_weight_constraint()
    )
    %CheckBoxStacksConstraint.toggled.connect(func(toggled_on: bool):
        if toggled_on:
            if !is_instance_valid(inventory.get_stacks_constraint()):
                inventory.enable_stacks_constraint()
        else:
            if is_instance_valid(inventory.get_stacks_constraint()):
                inventory.disable_stacks_constraint()
    )
    %CheckBoxGridConstraint.toggled.connect(func(toggled_on: bool):
        if toggled_on:
            if !is_instance_valid(inventory.get_grid_constraint()):
                inventory.enable_grid_constraint()
        else:
            if is_instance_valid(inventory.get_grid_constraint()):
                inventory.disable_grid_constraint()
    )

    %LineEditCapacity.text_submitted.connect(func(new_text: String):
        if is_instance_valid(inventory.get_weight_constraint()):
            inventory.get_weight_constraint().capacity = float(new_text)
            _on_capacity_changed()
    )

    %LineEditSizeX.text_submitted.connect(func(new_text: String):
        if is_instance_valid(inventory.get_grid_constraint()):
            inventory.get_grid_constraint().size = Vector2i(int(new_text), inventory.get_grid_constraint().size.y)
            _on_size_changed()
    )

    %LineEditSizeY.text_submitted.connect(func(new_text: String):
        if is_instance_valid(inventory.get_grid_constraint()):
            inventory.get_grid_constraint().size = Vector2i(inventory.get_grid_constraint().size.x, int(new_text))
            _on_size_changed()
    )


func _refresh() -> void:
    %CheckBoxWeightConstraint.disabled = true
    %CheckBoxStacksConstraint.disabled = true
    %CheckBoxGridConstraint.disabled = true
    _on_constraint_disabled(Inventory.Constraint.WEIGHT)
    _on_constraint_disabled(Inventory.Constraint.STACKS)
    _on_constraint_disabled(Inventory.Constraint.GRID)
    
    if !is_instance_valid(inventory):
        return

    %CheckBoxWeightConstraint.disabled = false
    %CheckBoxStacksConstraint.disabled = false
    %CheckBoxGridConstraint.disabled = false
    if is_instance_valid(inventory.get_weight_constraint()):
        _on_constraint_enabled(Inventory.Constraint.WEIGHT)
    if is_instance_valid(inventory.get_stacks_constraint()):
        _on_constraint_enabled(Inventory.Constraint.STACKS)
    if is_instance_valid(inventory.get_grid_constraint()):
        _on_constraint_enabled(Inventory.Constraint.GRID)

