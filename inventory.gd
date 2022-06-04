extends Node
class_name Inventory

signal item_added;
signal item_removed;
signal contents_changed;

export(Resource) var item_definitions setget _set_item_definitions;
export(Array, String) var contents;


func _set_item_definitions(new_item_definitions: Resource) -> void:
    item_definitions = new_item_definitions;

    assert(item_definitions is ItemDefinitions, \
            "item_definitions must be an ItemDefinitions resource!");


static func get_item_script() -> Script:
    return preload("inventory_item.gd");


func _ready() -> void:
    _populate();


func _populate() -> void:
    for prototype_id in contents:
        var item_def: Dictionary = item_definitions.get(prototype_id);
        assert(!item_def.empty(), "Undefined item id '%s'" % prototype_id);
        var item = get_item_script().new();
        item.prototype_id = prototype_id;
        item.item_definitions = item_definitions;
        assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.prototype_id);


func get_items() -> Array:
    return get_children();


func has_item(item: InventoryItem) -> bool:
    return item.get_parent() == self;


func add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false;

    if item.get_parent():
        item.get_parent().remove_child(item);

    add_child(item);
    if !item.is_connected("tree_exited", self, "_on_item_tree_exited"):
        item.connect("tree_exited", self, "_on_item_tree_exited", [item]);
    emit_signal("item_added", item);
    emit_signal("contents_changed");
    return true;


func remove_item(item: InventoryItem) -> bool:
    if item == null || !has_item(item):
        return false;

    if item.is_connected("tree_exited", self, "_on_item_tree_exited"):
        item.disconnect("tree_exited", self, "_on_item_tree_exited");
    remove_child(item);
    emit_signal("item_removed", item);
    emit_signal("contents_changed");
    return true;


func _on_item_tree_exited(item: InventoryItem) -> void:
    emit_signal("contents_changed");
    emit_signal("item_removed", item);


func get_item_by_id(id: String) -> InventoryItem:
    for item in get_children():
        if item.prototype_id == id:
            return item;
            
    return null;


func has_item_by_id(id: String) -> bool:
    return get_item_by_id(id) != null;


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    if remove_item(item):
        return destination.add_item(item);

    return false;

