extends TestSuite

var inventory1: Inventory
var inventory2: Inventory
var slot: ItemSlot
var item: InventoryItem


func init_suite():
    tests = [
        "test_can_hold_item",
        "test_inventory_changed",
        "test_item_removed",
        "test_serialize",
        "test_serialize_json"
    ]


func init_test() -> void:
    inventory1 = Inventory.new()
    inventory1.item_protoset = preload("res://tests/data/item_definitions_basic.tres")
    inventory2 = Inventory.new()
    inventory2.item_protoset = preload("res://tests/data/item_definitions_basic.tres")
    item = inventory1.create_and_add_item("minimal_item");
    slot = ItemSlot.new()


func cleanup_test() -> void:
    clear_inventory(inventory1)
    free_if_valid(inventory1)
    clear_inventory(inventory2)
    free_if_valid(inventory2)
    free_if_valid(item)
    free_if_valid(slot)


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


func test_serialize_json() -> void:
    slot.inventory = inventory1
    slot.item = item
    var item_slot_data = slot.serialize()

    # To and from JSON serialization
    var json_string = JSON.print(item_slot_data)
    var res: JSONParseResult = JSON.parse(json_string)
    assert(res.error == OK)
    item_slot_data = res.result

    slot.reset()
    assert(slot.inventory == null)
    assert(slot.item == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.inventory == inventory1)
    assert(slot.item == item)
