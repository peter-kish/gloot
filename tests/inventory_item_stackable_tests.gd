extends Test


func run_tests():
    var inventory = $InventoryStacked;
    var item = inventory.get_items()[0];

    assert(item.split(5) != null);
    assert(inventory.get_items().size() == 2);
    var item1 = inventory.get_items()[0];
    var item2 = inventory.get_items()[1];
    assert(item1.stack_size == 5);
    assert(item2.stack_size == 5);
    assert(item1.join(item2));
    assert(item1.stack_size == 10);
    assert(inventory.get_items().size() == 1);


