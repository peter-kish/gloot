extends TestSuite

const TEST_PROTOSET = preload("res://tests/data/protoset_basic.json")
const TEST_PROTOTYPE_ID = "minimal_item"

var slot: ItemSlot
var slot2: ItemSlot
var item: InventoryItem
var item2: InventoryItem
var inventory: Inventory


func init_suite():
    tests = [
        "test_equip_item",
        "test_add_item_to_inventory",
        "test_equip_item_in_two_slots",
        "test_can_hold_item",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    item = InventoryItem.new(TEST_PROTOSET, TEST_PROTOTYPE_ID)
    item2 = InventoryItem.new(TEST_PROTOSET, TEST_PROTOTYPE_ID)
    inventory = Inventory.new()
    inventory.protoset = TEST_PROTOSET
    inventory.add_item(item)
    inventory.add_item(item2)
    slot = ItemSlot.new()
    slot.protoset = TEST_PROTOSET
    slot2 = ItemSlot.new()
    slot2.protoset = TEST_PROTOSET


func cleanup_test() -> void:
    free_inventory(inventory)
    free_slot(slot)
    free_slot(slot2)


func test_equip_item() -> void:
    assert(slot.get_item() == null)
    assert(slot.equip(item))
    assert(slot.get_item() == item)

    assert(slot.equip(item2))
    assert(slot.get_item() == item2)

    slot.clear()
    assert(slot.get_item() == null)


func test_add_item_to_inventory() -> void:
    assert(slot.equip(item))
    assert(inventory.add_item(item))
    assert(slot.get_item() == null)
    assert(slot.equip(item))
    assert(!inventory.has_item(item))


func test_equip_item_in_two_slots() -> void:
    assert(slot.equip(item))
    assert(slot2.equip(item))
    assert(slot.get_item() == null)
    assert(slot2.get_item() == item)


func test_can_hold_item() -> void:
    assert(slot.can_hold_item(item))
    assert(!slot.can_hold_item(null))


func test_serialize() -> void:
    assert(slot.equip(item))
    var expected_protoset := item.protoset
    var expected_prototype_id := item._prototype.get_prototype_id()
    var expected_properties := item.get_properties()

    var item_slot_data = slot.serialize()
    slot.clear()
    assert(slot.get_item() == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.get_item().protoset == expected_protoset)
    assert(slot.get_item().get_prototype().get_prototype_id() == expected_prototype_id)
    assert(slot.get_item().get_properties() == expected_properties)


func test_serialize_json() -> void:
    assert(slot.equip(item))
    var expected_protoset := item.protoset
    var expected_prototype_id := item._prototype.get_prototype_id()
    var expected_properties := item.get_properties()

    var item_slot_data = slot.serialize()

    # To and from JSON serialization
    var json_string: String = JSON.stringify(item_slot_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    item_slot_data = test_json_conv.data

    slot.clear()
    assert(slot.get_item() == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.get_item().protoset == expected_protoset)
    assert(slot.get_item().get_prototype().get_prototype_id() == expected_prototype_id)
    assert(slot.get_item().get_properties() == expected_properties)
