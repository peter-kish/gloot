extends Inventory
class_name InventoryGrid
tool

signal size_changed;

const KEY_WIDTH: String = "width";
const KEY_HEIGHT: String = "height";

export(int, 1, 100) var width: int = 10 setget _set_width;
export(int, 1, 100) var height: int = 10 setget _set_height;

var _item_positions: Array = [];


class Vector2i:    
    var x: int;
    var y: int;


    func _init(x_: int, y_:int):
        x = x_;
        y = y_;


    func _to_string():
        return "(%s, %s)" % [x, y];


    func area() -> int:
        return x * y;


class Rect2i:
    var position: Vector2i;
    var size: Vector2i;


    func _init(position_: Vector2i, size_: Vector2i):
        position = position_;
        size = size_;


    func _to_string():
        return "(%s, %s, %s, %s)" % [position.x, position.y, size.x, size.y];


    func to_rect2() -> Rect2:
        return Rect2(position.x, position.y, size.x, size.y);


    func intersects(r: Rect2i) -> bool:
        var rect1 = r.to_rect2();
        var rect2 = to_rect2();
        return rect1.intersects(rect2);


class Space:
    var capacity: Vector2i;
    var reserved_rects: Array;


    func _init(capacity_: Vector2i):
        capacity = capacity_;


    func reserve(size: Vector2i) -> bool:
        var free_rect = _find_free_space(size);
        if free_rect:
            reserved_rects.append(free_rect);
            return true;
        return false;


    func _find_free_space(size: Vector2i) -> Rect2i:
        for x in range(capacity.x - (size.x - 1)):
            for y in range(capacity.y - (size.y - 1)):
                var space_pos: Vector2i = Vector2i.new(x, y);
                var space_size: Vector2i = Vector2i.new(size.x, size.y);
                var space: Rect2i = Rect2i.new(space_pos, space_size);
                if _rect_free(space):
                    return space;
        return null;


    func _rect_free(rect: Rect2i) -> bool:
        if rect.position.x + rect.size.x > capacity.x:
            return false;
        if rect.position.y + rect.size.y > capacity.y:
            return false;
    
        for item_rect in reserved_rects:
            if rect.intersects(item_rect):
                return false;
    
        return true;


func _get_configuration_warning() -> String:
    if _is_full_by_default():
        return "Inventory capacity exceeded!";
    return "";


func _is_full_by_default() -> bool:
    var space: Space = Space.new(Vector2i.new(width, height));
    for prototype_id in contents:
        var prototype_size = _get_prototype_size(prototype_id);
        if !space.reserve(prototype_size):
            return true;
    return false;


func _get_prototype_size(prototype_id: String) -> Vector2i:
    if item_protoset:
        var width: int = item_protoset.get_item_property(prototype_id, KEY_WIDTH, 1);
        var height: int = item_protoset.get_item_property(prototype_id, KEY_HEIGHT, 1);
        return Vector2i.new(width, height);
    return Vector2i.new(1, 1);


func get_item_position(item: InventoryItem) -> Vector2:
    return _item_positions[_get_item_index(item)];


func _get_item_index(item: InventoryItem) -> int:
    var item_index: int = get_items().find(item);
    assert(item_index >= 0, "The inventory does not contain this item!");
    return item_index;


func get_item_size(item: InventoryItem) -> Vector2:
    var item_width: int = item.get_property(KEY_WIDTH, 1);
    var item_height: int = item.get_property(KEY_HEIGHT, 1);
    if item.get_property("rotated", false):
        var temp = item_width;
        item_width = item_height;
        item_height = temp;
    return Vector2(item_width, item_height);
    

func _ready():
    assert(width > 0, "Inventory width must be positive!");
    assert(height > 0, "Inventory height must be positive!");


func _set_width(new_width: int) -> void:
    assert(new_width > 0, "Inventory width must be positive!");
    var old_width = width;
    width = new_width;
    update_configuration_warning();
    if !Engine.editor_hint:
        if _bounds_broken():
            width = old_width;
    if width != old_width:
        emit_signal("size_changed");


func _set_height(new_height: int) -> void:
    assert(new_height > 0, "Inventory height must be positive!");
    var old_height = height;
    height = new_height;
    update_configuration_warning();
    if !Engine.editor_hint:
        if _bounds_broken():
            height = old_height;
    if height != old_height:
        emit_signal("size_changed");


func _bounds_broken() -> bool:
    for item in get_items():
        var item_pos = get_item_position(item);
        var item_size = get_item_size(item);
        if !rect_free(item_pos.x, item_pos.y, item_size.x, item_size.y, item):
            return true;

    return false;


func _set_contents(new_contents: Array) -> void:
    ._set_contents(new_contents);
    update_configuration_warning();


func _populate() -> void:
    contents.sort_custom(self, "_compare_prototypes");
    ._populate();


func _compare_prototypes(prototype_id_1: String, prototype_id_2: String) -> bool:
    var size_1 = _get_prototype_size(prototype_id_1);
    var size_2 = _get_prototype_size(prototype_id_2);
    return size_1.area() > size_2.area();


func add_item(item: InventoryItem) -> bool:
    var free_place = find_free_place(item);
    if free_place.empty():
        return false;

    return add_item_at(item, free_place.x, free_place.y);


func add_item_at(item: InventoryItem, x: int, y: int) -> bool:
    var item_size = get_item_size(item);
    if rect_free(x, y, item_size.x, item_size.y):
        if .add_item(item):
            _item_positions.append(Vector2(x, y));
            return true;

    return false;


func remove_item(item: InventoryItem) -> bool:
    if .remove_item(item):
        _item_positions.remove(_get_item_index(item));
        return true;
    return false;


func move_item(item: InventoryItem, x: int, y: int) -> bool:
    var item_size = get_item_size(item);
    if rect_free(x, y, item_size.x, item_size.y, item):
        _item_positions[_get_item_index(item)] = Vector2(x, y);
        emit_signal("contents_changed");
        return true;

    return false;


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    return transfer_to(item, destination, 0, 0);


func transfer_to(item: InventoryItem, destination: InventoryGrid, x: int, y: int) -> bool:
    var item_size = get_item_size(item);
    if destination.rect_free(x, y, item_size.x, item_size.y):
        if .transfer(item, destination):
            destination.move_item(item, x, y);
            return true;

    return false;


func rect_free(x: int, y: int, w: int, h: int, exception: InventoryItem = null) -> bool:
    if x + w > width:
        return false;
    if y + h > height:
        return false;

    for item in get_items():
        if item == exception:
            continue;
        var item_pos: Vector2 = get_item_position(item);
        var item_size: Vector2 = get_item_size(item);
        var rect1: Rect2 = Rect2(Vector2(x, y), Vector2(w, h));
        var rect2: Rect2 = Rect2(item_pos, item_size);
        if rect1.intersects(rect2):
            return false;

    return true;


func find_free_place(item: InventoryItem) -> Dictionary:
    var item_size = get_item_size(item);
    for x in range(width - (item_size.x - 1)):
        for y in range(height - (item_size.y - 1)):
            if rect_free(x, y, item_size.x, item_size.y, item):
                return {x = x, y = y};

    return {};


func _compare_items(item1: InventoryItem, item2: InventoryItem) -> bool:
    var rect1: Rect2 = Rect2(get_item_position(item1), get_item_size(item1));
    var rect2: Rect2 = Rect2(get_item_position(item2), get_item_size(item2));
    return rect1.get_area() > rect2.get_area();


func sort() -> bool:
    var item_array: Array;
    for item in get_items():
        item_array.append(item);
    item_array.sort_custom(self, "_compare_items");

    for item in get_items():
        remove_child(item);

    for item in item_array:
        var free_place: Dictionary = find_free_place(item);
        if free_place.empty():
            return false;
        add_item_at(item, free_place.x, free_place.y);

    return true;


func serialize() -> Dictionary:
    var result: Dictionary = .serialize();

    result["width"] = width;
    result["height"] = height;
    result["item_positions"] = _item_positions;

    return result;
