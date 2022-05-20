extends Inventory
class_name InventoryGrid

signal size_changed;

const KEY_WIDTH: String = "width";
const KEY_HEIGHT: String = "height";

export(int) var width: int = 10 setget _set_width;
export(int) var height: int = 10 setget _set_height;

var item_positions: Dictionary = {};


func _get_item_position(item: InventoryItem) -> Vector2:
    assert(item_positions.has(item), "The inventory does not contain this item!");
    return item_positions[item];


func _get_item_size(item: InventoryItemRect) -> Vector2:
    assert(item_positions.has(item), "The inventory does not contain this item!");
    if item_definitions:
        var width = item_definitions.get_item_property(item.item_id, KEY_WIDTH, 1.0);
        var height = item_definitions.get_item_property(item.item_id, KEY_HEIGHT, 1.0);
        if item.rotated:
            var temp = width;
            width = height;
            height = temp;
        return Vector2(width, height);
    else:
        return Vector2(1, 1);


static func get_type() -> String:
    return "grid";


static func get_item_script() -> Script:
    return preload("inventory_item_rect.gd");


func _ready():
    if !_is_sorted():
        assert(sort(), "Item sorting failed! Too many items?");
    assert(width > 0, "Inventory width must be positive!");
    assert(height > 0, "Inventory height must be positive!");


func _set_width(new_width: int) -> void:
    assert(new_width > 0, "Inventory width must be positive!");
    width = new_width;
    emit_signal("size_changed");


func _set_height(new_height: int) -> void:
    assert(new_height > 0, "Inventory height must be positive!");
    height = new_height;
    emit_signal("size_changed");


func add_item(item: InventoryItem) -> bool:
    assert(item is InventoryItemRect, "InventoryGrid can only hold InventoryItemRect")
    return add_item_at(item, 0, 0);


func add_item_at(item: InventoryItemRect, x: int, y: int) -> bool:
    var item_size = _get_item_size(item);
    if rect_free(x, y, item_size.x, item_size.y):
        item_positions[item] = Vector2(x, y);
        return .add_item(item);

    return false;


func remove_item(item: InventoryItem) -> bool:
    if .remove_item(item):
        assert(item_positions.has(item));
        item_positions.erase(item);
        return true;
    return false;


func move_item(item: InventoryItemRect, x: int, y: int) -> bool:
    var item_size = _get_item_size(item);
    if rect_free(x, y, item_size.x, item_size.y, item):
        item_positions[item] = Vector2(x, y);
        emit_signal("contents_changed");
        return true;

    return false;


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    return transfer_to(item, destination, 0, 0);


func transfer_to(item: InventoryItemRect, destination: InventoryGrid, x: int, y: int) -> bool:
    var item_size = _get_item_size(item);
    if destination.rect_free(x, y, item_size.x, item_size.y):
        return .transfer(item, destination);

    return false;


func rect_free(x: int, y: int, w: int, h: int, exception: InventoryItemRect = null) -> bool:
    if x + w > width:
        return false;
    if y + h > height:
        return false;

    for item in get_items():
        if item == exception:
            continue;
        var item_pos: Vector2 = _get_item_position(item);
        var item_size: Vector2 = _get_item_size(item);
        var rect1: Rect2 = Rect2(Vector2(x, y), Vector2(w, h));
        var rect2: Rect2 = Rect2(item_pos, item_size);
        if rect1.intersects(rect2):
            return false;

    return true;


func find_free_place(item: InventoryItemRect) -> Dictionary:
    var item_size = _get_item_size(item);
    for y in range(width - (item_size.x - 1)):
        for x in range(height - (item_size.y - 1)):
            if rect_free(x, y, item_size.x, item_size.y):
                return {x = x, y = y};

    return {};


func _sort_items(item1: InventoryItemRect, item2: InventoryItemRect) -> bool:
    var rect1: Rect2 = Rect2(_get_item_position(item1), _get_item_size(item1));
    var rect2: Rect2 = Rect2(_get_item_position(item2), _get_item_size(item2));
    return rect1.get_area() > rect2.get_area();


func sort() -> bool:
    var item_array: Array;
    for item in get_items():
        item_array.append(item);
    item_array.sort_custom(self, "_sort_items");

    for item in get_items():
        remove_child(item);

    for item in item_array:
        var free_place: Dictionary = find_free_place(item);
        if free_place.empty():
            return false;
        add_item_at(item, free_place.x, free_place.y);

    return true;


func _is_sorted() -> bool:
    for item in get_items():
        var item_pos = _get_item_position(item);
        var item_size = _get_item_size(item);
        if !rect_free(item_pos.x, item_pos.y, item_size.x, item_size.y, item):
            return false;

    return true;
