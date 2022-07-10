extends TestSuite

var inventory1: Inventory
var inventory2: Inventory
var slot: ItemSlot
var item: InventoryItem


func init_suite():
    inventory1 = $Inventory1
    inventory2 = $Inventory2
    slot = $ItemSlot
    item = inventory1.get_items()[0]

    tests = [
        "test_can_hold_item",
        "test_inventory_changed",
        "test_item_removed",
        "test_serialize"
    ]


func init_test() -> void:
    inventory1.remove_all_items()
    inventory2.remove_all_items()
    inventory1.add_item(item)
    slot.item = null
    slot.inventory = null


func test_can_hold_item() -> void:
    assert(!slot.can_hold_item(item))
    slot.inventory = inventory2
    assert(!slot.can_hold_item(item))
    slot.inventory = inventory1
    assert(slot.can_hold_item(item))
    

func test_inventory_changed() -> void:
    slot.inventory = inventory1
    slot.item = item
    assert(slot.item == item)
    slot.inventory = inventory2
    assert(slot.item == null)
    
    
func test_item_removed() -> void:
    slot.inventory = inventory2
    inventory1.transfer(item, inventory2)
    assert(slot.can_hold_item(item))
    slot.item = item
    assert(slot.item == item)
    inventory2.remove_item(item)
    assert(slot.item == null)
    

func test_serialize() -> void:
    slot.inventory = inventory1
    slot.item = item
    var item_slot_data = slot.serialize()
    slot.reset()
    assert(slot.inventory == null)
    assert(slot.item == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.inventory == inventory1)
    assert(slot.item == item)
