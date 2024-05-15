extends TestSuite

const TEST_PROTOTREE = preload("res://tests/data/prototree_basic.json")
const TEST_PROTOTYPE_PATH = "/minimal_item"

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
        "test_reset",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    item = InventoryItem.new(TEST_PROTOTREE, TEST_PROTOTYPE_PATH)
    item2 = InventoryItem.new(TEST_PROTOTREE, TEST_PROTOTYPE_PATH)
    inventory = Inventory.new()
    inventory.prototree_json = TEST_PROTOTREE
    inventory.add_item(item)
    inventory.add_item(item2)
    slot = ItemSlot.new()
    slot.prototree_json = TEST_PROTOTREE
    slot2 = ItemSlot.new()
    slot2.prototree_json = TEST_PROTOTREE


func cleanup_test() -> void:
    free_inventory(inventory)
    free_slot(slot)
    free_slot(slot2)


func test_equip_item() -> void:
    assert(slot.get_item() == null)
    assert(slot.equip(item))
    assert(slot.get_item() == item)
    assert(item.get_item_slot() == slot)

    assert(slot.equip(item2))
    assert(slot.get_item() == item2)
    assert(item2.get_item_slot() == slot)

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


func test_reset() -> void:
    assert(slot.equip(item))
    slot.reset()
    assert(slot.get_item() == null)


func test_serialize() -> void:
    assert(slot.equip(item))
    var expected_prototree_json := item._prototree_json
    var expected_prototype_path := item._prototype.get_path()
    var expected_properties := item.get_properties()

    var item_slot_data = slot.serialize()
    slot.reset()
    assert(slot.get_item() == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.get_item()._prototree_json == expected_prototree_json)
    assert(slot.get_item().get_prototype().get_path().equal(expected_prototype_path))
    assert(slot.get_item().get_properties() == expected_properties)


func test_serialize_json() -> void:
    assert(slot.equip(item))
    var expected_prototree_json := item._prototree_json
    var expected_prototype_path := item._prototype.get_path()
    var expected_properties := item.get_properties()

    var item_slot_data = slot.serialize()

    # To and from JSON serialization
    var json_string: String = JSON.stringify(item_slot_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    item_slot_data = test_json_conv.data

    slot.reset()
    assert(slot.get_item() == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.get_item()._prototree_json == expected_prototree_json)
    assert(slot.get_item().get_prototype().get_path().equal(expected_prototype_path))
    assert(slot.get_item().get_properties() == expected_properties)
