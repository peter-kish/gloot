extends Test


func run_tests():
    var inventory = $Inventory;

    assert(inventory.get_type() == "basic" );

    var items = inventory.get_items();
    assert(items.size() == 2);

