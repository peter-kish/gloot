extends Test


func run_tests():
    var inventory_3x3 = $InventoryGrid3x3
    var item_1x1 = $Item_1x1
    var item_2x2 = $Item_2x2

    assert(!inventory_3x3.add_item_at(item_1x1, 4, 4))
    assert(!inventory_3x3.add_item_at(item_1x1, 3, 3))
    assert(inventory_3x3.add_item_at(item_1x1, 0, 0))

    assert(!inventory_3x3.add_item_at(item_2x2, 0, 0))
    assert(!inventory_3x3.add_item_at(item_2x2, 2, 2))
    var free_place: Dictionary = inventory_3x3.find_free_place(item_2x2)
    assert(free_place.x == 0)
    assert(free_place.y == 1)
    assert(inventory_3x3.add_item_at(item_2x2, 1, 0))

    inventory_3x3.height = 2
    assert(inventory_3x3.height == 2)
    inventory_3x3.height = 3
    assert(inventory_3x3.height == 3)
    inventory_3x3.width = 2
    assert(inventory_3x3.width == 3)

    var inventory_data = inventory_3x3.serialize()
    inventory_3x3.reset()
    assert(inventory_3x3.get_items().empty())
    assert(inventory_3x3.width == InventoryGrid.DEFAUL_WIDTH)
    assert(inventory_3x3.height == InventoryGrid.DEFAUL_HEIGHT)
    assert(inventory_3x3.deserialize(inventory_data))
    assert(inventory_3x3.get_items().size() == 2)
    assert(inventory_3x3.width == 3)
    assert(inventory_3x3.height == 3)
