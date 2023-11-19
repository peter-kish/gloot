@tool
extends Label

@export var inventory_path: NodePath :
    get:
        return inventory_path
    set(new_inv_path):
        inventory_path = new_inv_path
        inventory = get_node_or_null(inventory_path)

var inventory: Inventory = null :
    get:
        return inventory
    set(new_inventory):
        if inventory == new_inventory:
            return

        if inventory != null:
            _disconnect_inventory_signals()
        inventory = new_inventory
        _refresh()
        if inventory != null:
            _connect_inventory_signals()


func _connect_inventory_signals() -> void:
    if !inventory.is_node_ready():
        inventory.ready.connect(_refresh)
    inventory.contents_changed.connect(_refresh)
    inventory.protoset_changed.connect(_refresh)
    if inventory.get_weight_constraint():
        inventory.get_weight_constraint().capacity_changed.connect(_refresh)
        inventory.get_weight_constraint().occupied_space_changed.connect(_refresh)


func _disconnect_inventory_signals() -> void:
    if inventory.ready.is_connected(_refresh):
        inventory.ready.disconnect(_refresh)
    inventory.contents_changed.disconnect(_refresh)
    inventory.protoset_changed.disconnect(_refresh)
    if inventory.get_weight_constraint():
        inventory.get_weight_constraint().capacity_changed.disconnect(_refresh)
        inventory.get_weight_constraint().occupied_space_changed.disconnect(_refresh)


func _refresh() -> void:
    text = ""
    if inventory == null || !inventory.is_node_ready():
        return

    var weight_constraint := inventory.get_weight_constraint()
    if weight_constraint == null:
        return

    if weight_constraint.has_unlimited_capacity():
        text = "%s/INF" % str(weight_constraint.occupied_space)
    else:
        text = "%s/%s" % [str(weight_constraint.occupied_space), str(weight_constraint.capacity)]


func _ready() -> void:
    if !inventory_path.is_empty():
        inventory = get_node_or_null(inventory_path)

    _refresh()

