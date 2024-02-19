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
        "test_equip_item",
        "test_delete_item",
        "test_add_item_to_inventory",
        "test_return_item_to_source_inventory",
        "test_equip_item_in_two_slots",
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
    inventory.add_item(item)
    inventory.add_item(item2)
    slot = ItemSlot.new()
    slot.item_protoset = TEST_PROTOSET
    slot2 = ItemSlot.new()
    slot2.item_protoset = TEST_PROTOSET


func cleanup_test() -> void:
    free_item(item)
    free_item(item2)
    free_inventory(inventory)
    free_slot(slot)
    free_slot(slot2)


func test_equip_item() -> void:
    assert(slot.get_item() == null)
    assert(slot.equip(item))
    assert(slot.get_item() == item)
    assert(item.get_parent() == slot)
    assert(slot.get_child_count() == 1)

    assert(slot.equip(item2))
    assert(slot.get_item() == item2)
    assert(item2.get_parent() == slot)
    assert(slot.get_child_count() == 1)

    slot.clear()
    assert(slot.get_item() == null)
    assert(slot.get_child_count() == 0)


func test_delete_item() -> void:
    assert(slot.equip(item))
    item.free()
    assert(slot.get_item() == null)


func test_add_item_to_inventory() -> void:
    assert(slot.equip(item))
    assert(inventory.add_item(item))
    assert(slot.get_item() == null)
    assert(slot.equip(item))
    assert(!inventory.has_item(item))


func test_return_item_to_source_inventory() -> void:
    assert(slot.equip(item))
    assert(!inventory.has_item(item))
    assert(slot.clear())
    assert(inventory.has_item(item))

    slot.remember_source_inventory = false
    assert(slot.equip(item))
    assert(slot.clear())
    assert(!inventory.has_item(item))
    slot.remember_source_inventory = true

    assert(inventory.add_item(item))
    assert(slot.equip(item))
    assert(slot.equip(item2))
    assert(inventory.has_item(item))

    slot.remember_source_inventory = false
    assert(inventory.add_item(item2))
    assert(slot.equip(item))
    assert(slot.equip(item2))
    assert(!inventory.has_item(item))
    slot.remember_source_inventory = true

    assert(slot.equip(item))
    assert(slot.clear())
    assert(slot.get_item() == null)
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
    var item_slot_data = slot.serialize()
    slot.get_item().queue_free()
    slot.reset()
    assert(slot.get_item() == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.get_item().protoset == item.protoset)
    assert(slot.get_item().prototype_id == item.prototype_id)
    assert(slot.get_item().properties == item.properties)


func test_serialize_json() -> void:
    assert(slot.equip(item))
    var item_slot_data = slot.serialize()

    # To and from JSON serialization
    var json_string: String = JSON.stringify(item_slot_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    item_slot_data = test_json_conv.data

    slot.get_item().queue_free()
    slot.reset()
    assert(slot.get_item() == null)
    assert(slot.deserialize(item_slot_data))
    assert(slot.get_item().protoset == item.protoset)
    assert(slot.get_item().prototype_id == item.prototype_id)
    assert(slot.get_item().properties == item.properties)
