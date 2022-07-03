extends TestSuite

var inventory: Inventory


func init_suite():
    inventory = $Inventory
    tests = ["test_item_count"]


func test_item_count():
    var items = inventory.get_items()
    assert(items.size() == 2)

