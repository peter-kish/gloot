extends Test


func run_tests():
    var inventory = $Inventory;

    var items = inventory.get_items();
    assert(items.size() == 2);

