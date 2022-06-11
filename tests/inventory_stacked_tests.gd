extends Test


func run_tests():
    var inventory = $InventoryStacked;
    var item = $MinimalItem;
    var big_item = $BigItem;
    var stackable_item = $StackableItem;

    assert(inventory.capacity == 10.0);
    assert(inventory.get_free_space() == 10.0);
    assert(inventory.occupied_space == 0.0);
    assert(inventory.has_place_for(item));
    assert(inventory.add_item(item));
    assert(inventory.occupied_space == 1.0);
    assert(inventory.get_free_space() == 9.0);
    assert(inventory.remove_item(item));

    assert(!inventory.has_place_for(big_item));
    assert(!inventory.add_item(big_item));

    inventory.capacity = 0.5;
    assert(!inventory.has_place_for(item));
    assert(!inventory.add_item(item));

    inventory.capacity = 0;
    assert(inventory.has_place_for(item));
    assert(inventory.add_item(item));
    assert(inventory.has_place_for(big_item));
    assert(inventory.add_item(big_item));
    assert(inventory.remove_item(item));
    assert(inventory.remove_item(big_item));

    inventory.capacity = 10.0;
    assert(inventory.add_item(item));
    assert(inventory.occupied_space == 1.0);
    item.queue_free();
    yield(inventory, "contents_changed");
    assert(inventory.occupied_space == 0.0);

    assert(inventory.add_item(stackable_item));
    assert(inventory.split(stackable_item, 5) != null);
    assert(inventory.get_items().size() == 2);
    var item1 = inventory.get_items()[0];
    var item2 = inventory.get_items()[1];
    assert(item1.get_property(InventoryStacked.KEY_STACK_SIZE) == 5);
    assert(item2.get_property(InventoryStacked.KEY_STACK_SIZE) == 5);
    assert(item1.join(item2));
    assert(item1.get_property(InventoryStacked.KEY_STACK_SIZE) == 10);
    assert(inventory.get_items().size() == 1);

