extends Test


func run_tests():
    var inventory1 = $Inventory1;
    var inventory2 = $Inventory2;

    assert(inventory1.get_items().size() == 1);

    assert(inventory1.has_item_by_id("minimal_item"));
    var item = inventory1.get_item_by_id("minimal_item");
    assert(inventory1.has_item(item));
    assert(inventory1.remove_item(item));
    assert(inventory1.add_item(item));
    
    assert(inventory1.transfer(item, inventory2));
    assert(!inventory1.has_item(item));
    assert(inventory2.has_item(item));

    assert(inventory2.remove_item(item));
    assert(!inventory2.has_item(item));
