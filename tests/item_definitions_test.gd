extends Test


var inventory: Inventory


func setup():
    inventory = $Inventory
    tests = ["test_item_count"]


func test_item_count():
    var items = inventory.get_items()
    assert(items.size() == 2)

