extends Test


var inventory: Inventory


func run_tests():
    inventory = $Inventory
    tests = ["test_item_count"]
    .run_tests()


func test_item_count():
    var items = inventory.get_items()
    assert(items.size() == 2)

