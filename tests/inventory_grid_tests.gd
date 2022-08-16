extends TestSuite

var inventory_3x3: InventoryGrid
var item_1x1: InventoryItem
var item_2x2: InventoryItem


func init_suite():
    inventory_3x3 = $InventoryGrid3x3
    item_1x1 = $Item_1x1
    item_2x2 = $Item_2x2

    tests = [
        "test_add_item_at",
        "test_find_free_place",
        "test_change_size",
        "test_create_and_add_item_at",
        "test_get_item_at",
        "test_serialize"
    ]


func init_test():
    inventory_3x3.remove_all_items()


func test_add_item_at() -> void:
    assert(!inventory_3x3.add_item_at(item_1x1, Vector2(4, 4)))
    assert(!inventory_3x3.add_item_at(item_1x1, Vector2(3, 3)))
    assert(inventory_3x3.add_item_at(item_1x1, Vector2(0, 0)))
    assert(!inventory_3x3.add_item_at(item_2x2, Vector2(0, 0)))
    assert(!inventory_3x3.add_item_at(item_2x2, Vector2(2, 2)))


func test_find_free_place() -> void:
    assert(inventory_3x3.add_item_at(item_1x1, Vector2(0, 0)))
    var free_place: Vector2 = inventory_3x3.find_free_place(item_2x2)
    assert(free_place.x == 0)
    assert(free_place.y == 1)
    assert(inventory_3x3.add_item_at(item_2x2, free_place))


func test_change_size() -> void:
    assert(inventory_3x3.add_item_at(item_1x1, Vector2(0, 0)))
    assert(inventory_3x3.add_item_at(item_2x2, Vector2(1, 0)))
    inventory_3x3.size.y = 2
    assert(inventory_3x3.size.y == 2)
    inventory_3x3.size.y = 3
    assert(inventory_3x3.size.y == 3)
    inventory_3x3.size.x = 2
    assert(inventory_3x3.size.x == 3)


func test_create_and_add_item_at() -> void:
    var new_item = inventory_3x3.create_and_add_item_at("item_1x1", Vector2(1, 1))
    assert(new_item)
    assert(inventory_3x3.get_items().size() == 1)
    assert(inventory_3x3.has_item(new_item))
    assert(inventory_3x3.has_item_by_id("item_1x1"))
    assert(inventory_3x3.get_item_position(new_item) == Vector2(1, 1))


func test_get_item_at() -> void:
    assert(inventory_3x3.add_item_at(item_2x2, Vector2(1, 1)))
    assert(inventory_3x3.get_item_at(Vector2(0, 0)) == null)
    assert(inventory_3x3.get_item_at(Vector2(1, 1)) == item_2x2)
    assert(inventory_3x3.get_item_at(Vector2(2, 2)) == item_2x2)
    assert(inventory_3x3.move_item_to(item_2x2, Vector2(0, 0)))
    assert(inventory_3x3.get_item_at(Vector2(2, 2)) == null)
    assert(inventory_3x3.get_item_at(Vector2(0, 0)) == item_2x2)


func test_serialize():
    assert(inventory_3x3.add_item_at(item_1x1, Vector2(0, 0)))
    assert(inventory_3x3.add_item_at(item_2x2, Vector2(1, 0)))
    var inventory_data = inventory_3x3.serialize()
    inventory_3x3.reset()
    assert(inventory_3x3.get_items().empty())
    assert(inventory_3x3.size == InventoryGrid.DEFAULT_SIZE)
    assert(inventory_3x3.deserialize(inventory_data))
    assert(inventory_3x3.get_items().size() == 2)
    assert(inventory_3x3.size.x == 3)
    assert(inventory_3x3.size.y == 3)
