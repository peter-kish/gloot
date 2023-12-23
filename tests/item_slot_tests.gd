extends TestSuite

const TEST_PROTOSET = preload("res://tests/data/item_definitions_basic.tres")
const TEST_PROTOTYPE_ID = "minimal_item"

var slot: ItemSlot
var slot2: ItemSlot
var item: InventoryItem
var item2: InventoryItem
var inventory: Inventory


func init_suite():
    tests = [
        "test_set_item",
        "test_delete_item",
        "test_add_item_to_inventory",
        "test_set_item_in_two_slots",
        "test_can_hold_item",
        "test_reset",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    item = InventoryItem.new()
    item.protoset = TEST_PROTOSET
    item.prototype_id = TEST_PROTOTYPE_ID
    item2 = InventoryItem.new()
    item2.protoset = TEST_PROTOSET
    item2.prototype_id = TEST_PROTOTYPE_ID
    inventory = Inventory.new()
    inventory.item_protoset = TEST_PROTOSET
    slot = ItemSlot.new()
    slot.item_protoset = TEST_PROTOSET
    slot2 = ItemSlot.new()
    slot2.item_protoset = TEST_PROTOSET


func cleanup_test() -> void:
    if slot.item:
        slot.item.free()
    if slot2.item:
        slot2.item.free()
    free_item(item)
    free_item(item2)
    free_inventory(inventory)
    free_slot(slot)
    free_slot(slot2)


func test_set_item() -> void:
    assert(slot.item == null)
    slot.item = item
    assert(slot.item == item)
    assert(item.get_parent() == slot)
    assert(slot.get_child_count() == 1)

    slot.item = item2
    assert(slot.item == item2)
    assert(item2.get_parent() == slot)
    assert(slot.get_child_count() == 1)
    assert(item.get_parent() == null)

    slot.item = null
    assert(slot.item == null)
    assert(item2.get_parent() == null)
    assert(item.get_parent() == null)
    assert(slot.get_child_count() == 0)


func test_delete_item() -> void:
    slot.item = item
    item.free()
    assert(slot.item == null)


func test_add_item_to_inventory() -> void:
    slot.item = item
    inventory.add_item(item)
    assert(slot.item == null)
    slot.item = item
    assert(!inventory.has_item(item))


func test_set_item_in_two_slots() -> void:
    slot.item = item
    slot2.item = item
    assert(slot.item == null)
    assert(slot2.item == item)


func test_can_hold_item() -> void:
    assert(slot.can_hold_item(item))
    assert(!slot.can_hold_item(null))


func test_reset() -> void:
    slot.item = item
    slot.reset()
    assert(slot.item == null)


func test_serialize() -> void:
    slot.item = item
    var item_slot_data = slot.serialize()
    slot.reset()
    assert(slot.item == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.item.protoset == item.protoset)
    assert(slot.item.prototype_id == item.prototype_id)
    assert(slot.item.properties == item.properties)


func test_serialize_json() -> void:
    slot.item = item
    var item_slot_data = slot.serialize()

    # To and from JSON serialization
    var json_string: String = JSON.stringify(item_slot_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    item_slot_data = test_json_conv.data

    slot.reset()
    assert(slot.item == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.item.protoset == item.protoset)
    assert(slot.item.prototype_id == item.prototype_id)
    assert(slot.item.properties == item.properties)
