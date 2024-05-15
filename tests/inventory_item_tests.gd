extends TestSuite

var inventory: Inventory
var slot: ItemSlot
var item: InventoryItem

const TEST_PROTOTREE = preload("res://tests/data/prototree_basic.json")

func init_suite() -> void:
    tests = [
        "test_get_inventory",
        "test_get_item_slot",
        "test_swap",
        "test_get_property",
        "test_set_property",
        "test_references",
        "test_clear_property",
        "test_reset",
        "test_get_texture",
        "test_get_title",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    inventory = create_inventory(TEST_PROTOTREE)
    slot = ItemSlot.new()
    slot.prototree_json = TEST_PROTOTREE
    item = inventory.create_and_add_item("minimal_item")


func cleanup_test() -> void:
    free_inventory(inventory)
    free_slot(slot)


func test_get_inventory() -> void:
    assert(item.get_inventory() == inventory)
    inventory.remove_item(item)
    assert(item.get_inventory() == null)


func test_get_item_slot() -> void:
    assert(item.get_item_slot() == null)
    inventory.remove_item(item)
    slot.equip(item)
    assert(item.get_item_slot() == slot)


func test_swap() -> void:
    var inventory2 = create_inventory(TEST_PROTOTREE)
    var item2 = inventory2.create_and_add_item("minimal_item")
    var slot2 = ItemSlot.new()
    slot2.prototree_json = TEST_PROTOTREE

    # Swap items between two inventories
    assert(InventoryItem.swap(item, item2))
    assert(item.get_inventory() == inventory2)
    assert(item.get_item_slot() == null)
    assert(item2.get_inventory() == inventory)
    assert(item2.get_item_slot() == null)

    # Swap items between an inventory and a slot
    inventory.add_item(item)
    slot2.equip(item2)
    assert(InventoryItem.swap(item, item2))
    assert(item.get_inventory() == null)
    assert(item.get_item_slot() == slot2)
    assert(item2.get_inventory() == inventory)
    assert(item2.get_item_slot() == null)

    # Swap items between two slots
    slot.equip(item)
    slot2.equip(item2)
    assert(InventoryItem.swap(item, item2))
    assert(item.get_inventory() == null)
    assert(item.get_item_slot() == slot2)
    assert(item2.get_inventory() == null)
    assert(item2.get_item_slot() == slot)

    # Swap within one inventory
    inventory.add_item(item)
    inventory.add_item(item2)
    var idx = inventory.get_item_index(item)
    var idx2 = inventory.get_item_index(item2)
    assert(InventoryItem.swap(item, item2))
    assert(item.get_inventory() == inventory)
    assert(item.get_item_slot() == null)
    assert(item2.get_inventory() == inventory)
    assert(item2.get_item_slot() == null)
    assert(inventory.get_item_index(item) == idx2)
    assert(inventory.get_item_index(item2) == idx)

    free_inventory(inventory2)
    free_slot(slot2)


func test_get_property() -> void:
    assert(item.get_property("name", "none") == "none")
    var item2 := inventory.create_and_add_item("/item1")
    assert(item2.get_property("name", "none") == "item 1")


func test_set_property() -> void:
    item.set_property("name", "Bob")
    assert(item.get_property("name") == "Bob")


func test_references() -> void:
    var item2 := create_item(preload("res://tests/data/prototree_dict.json"), "containing_dict")
    var dict: Dictionary = item2.get_property("dictionary")
    assert(dict != null)
    assert(dict.has("foo"))
    assert(dict["foo"] == "bar")
    assert(dict.has("baz"))
    assert(dict["baz"] == 42)
    dict["baz"] = 43
    assert(item2.get_property("dictionary")["baz"] == 42)
    item2.set_property("dictionary", dict)
    assert(item2.get_property("dictionary")["baz"] == 43)
    


func test_clear_property() -> void:
    item.set_property("name", "Bob")
    item.clear_property("name")
    assert(item.get_property("name", "none") == "none")

    var item2 := inventory.create_and_add_item("/item1")
    item2.set_property("name", "Bob")
    assert(item2.get_property("name", "none") == "Bob")
    item2.clear_property("name")
    assert(item2.get_property("name", "none") == "item 1")


func test_reset() -> void:
    item.set_property("foo", "bar")

    item.reset()
    assert(item._prototree_json == inventory.prototree_json)
    assert(item.get_prototype() != null)
    assert(PrototypePath.str_paths_equal(str(item.get_prototype().get_path()), "/minimal_item"))
    assert(item.get_overridden_properties().is_empty())
    assert(!item.has_property("foo"))

    inventory.remove_item(item)
    item.reset()
    assert(item._prototree_json == null)
    assert(item.get_prototype() == null)
    assert(item.get_overridden_properties().is_empty())


func test_get_texture() -> void:
    assert(item.get_texture() == null)
    var item2 := inventory.create_and_add_item("/item1")
    assert(item2.get_texture() != null)
    assert(item2.get_texture().resource_path == "res://images/item_book_blue.png")


func test_get_title() -> void:
    assert(item.get_title() == "minimal_item")
    var item2 := inventory.create_and_add_item("/item1")
    assert(item2.get_title() == "item 1")


func test_serialize() -> void:
    item.set_property("foo", "bar")
    var item_data := item.serialize()
    item.reset()
    assert(item.get_property("foo") == null)
    assert(item.deserialize(item_data))
    assert(item.get_property("foo") == "bar")


func test_serialize_json() -> void:
    item.set_property("foo", "bar")
    var item_data := item.serialize()

    # To and from JSON serialization
    var json_string: String = JSON.stringify(item_data)
    var test_json_conv: JSON = JSON.new()
    assert(test_json_conv.parse(json_string) == OK)
    item_data = test_json_conv.data

    item.reset()
    assert(item.get_property("foo") == null)
    assert(item.deserialize(item_data))
    assert(item.get_property("foo") == "bar")

