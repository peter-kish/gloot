extends Inventory
class_name InventoryGrid

signal size_changed;


export(int) var width: int = 10 setget _set_width;
export(int) var height: int = 10 setget _set_height;


func _ready():
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
    assert(false, "Can't use add_item() with InventoryGrid! Use add_item_at() instead!");
    return false;


func add_item_at(item: InventoryItemRect, x: int, y: int) -> bool:
    if rect_free(x, y, item.width, item.height):
        item.x = x;
        item.y = y;
        return .add_item(item);

    return false;


func move_item(item: InventoryItemRect, x: int, y: int) -> bool:
    if rect_free(x, y, item.width, item.height, item):
        item.x = x;
        item.y = y;
        emit_signal("contents_changed");
        return true;

    return false;


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    assert(false, "Can't use transfer() with InventoryGrid! Use transfer_to() instead!");
    return false;


func transfer_to(item: InventoryItemRect, destination: InventoryGrid, x: int, y: int) -> bool:
    if destination.rect_free(x, y, item.width, item.height):
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
        var rect1: Rect2 = Rect2(Vector2(x, y), Vector2(w, h));
        var rect2: Rect2 = Rect2(Vector2(item.x, item.y), Vector2(item.width, item.height));
        if rect1.intersects(rect2):
            return false;

    return true;


func find_free_place(item: InventoryItemRect) -> Dictionary:
    for y in range(width - (item.width - 1)):
        for x in range(height - (item.height - 1)):
            if rect_free(x, y, item.width, item.height):
                return {x = x, y = y};

    return {};


static func _sort_items(item1: InventoryItemRect, item2: InventoryItemRect) -> bool:
    var rect1: Rect2 = Rect2(Vector2(item1.x, item1.y), Vector2(item1.width, item1.height));
    var rect2: Rect2 = Rect2(Vector2(item2.x, item2.y), Vector2(item2.width, item2.height));
    return rect1.get_area() > rect2.get_area();


func sort() -> void:
    var item_array: Array;
    for item in get_items():
        item_array.append(item);
    item_array.sort_custom(self, "_sort_items");

    for item in get_items():
        remove_child(item);

    for item in item_array:
        var free_place: Dictionary = find_free_place(item);
        assert(free_place.x != null, "Unexpected error in sort()! No free space!");
        assert(free_place.y != null, "Unexpected error in sort()! No free space!");
        add_item_at(item, free_place.x, free_place.y);
