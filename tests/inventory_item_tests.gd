extends TestSuite

var inventory: Inventory
var slot: ItemSlot
var item: InventoryItem

const TEST_PROTOSET = preload("res://tests/data/protoset_basic.json")

func init_suite() -> void:
    tests = [
        "test_get_inventory",
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
    inventory = create_inventory(TEST_PROTOSET)
    slot = ItemSlot.new()
    slot.protoset = TEST_PROTOSET
    item = inventory.create_and_add_item("minimal_item")


func cleanup_test() -> void:
    free_inventory(inventory)
    free_slot(slot)


func test_get_inventory() -> void:
    assert(item.get_inventory() == inventory)
    inventory.remove_item(item)
    assert(item.get_inventory() == null)


func test_swap() -> void:
    var inventory2 = create_inventory(TEST_PROTOSET)
    var item2 = inventory2.create_and_add_item("minimal_item")
    var slot2 = ItemSlot.new()
    slot2.protoset = TEST_PROTOSET

    # Swap items between two inventories
    assert(InventoryItem.swap(item, item2))
    assert(item.get_inventory() == inventory2)
    assert(item2.get_inventory() == inventory)

    # Swap within one inventory
    inventory.add_item(item)
    inventory.add_item(item2)
    var idx = inventory.get_item_index(item)
    var idx2 = inventory.get_item_index(item2)
    assert(InventoryItem.swap(item, item2))
    assert(item.get_inventory() == inventory)
    assert(item2.get_inventory() == inventory)
    assert(inventory.get_item_index(item) == idx2)
    assert(inventory.get_item_index(item2) == idx)

    free_inventory(inventory2)
    free_slot(slot2)


func test_get_property() -> void:
    assert(item.get_property("name", "none") == "none")
    var item2 := inventory.create_and_add_item("item1")
    assert(item2.get_property("name", "none") == "item 1")
    item2.set_property("name", "item 2")
    assert(item2.get_property("name", "none") == "item 2")
    var properties := item2.get_properties()
    assert(properties.size() == 2)
    assert("name" in properties)
    assert("image" in properties)


func test_set_property() -> void:
    item.set_property("name", "Bob")
    assert(item.get_property("name") == "Bob")


func test_references() -> void:
    var item2 := create_item(preload("res://tests/data/protoset_dict.json"), "containing_dict")
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

    var item2 := inventory.create_and_add_item("item1")
    item2.set_property("name", "Bob")
    assert(item2.get_property("name", "none") == "Bob")
    item2.clear_property("name")
    assert(item2.get_property("name", "none") == "item 1")


func test_reset() -> void:
    item.set_property("foo", "bar")

    item.reset()
    assert(item.protoset == inventory.protoset)
    assert(item.get_prototype() != null)
    assert(item.get_prototype().get_prototype_id() == "minimal_item")
    assert(item.get_overridden_properties().is_empty())
    assert(!item.has_property("foo"))

    inventory.remove_item(item)
    item.reset()
    assert(item.protoset == null)
    assert(item.get_prototype() == null)
    assert(item.get_overridden_properties().is_empty())


func test_get_texture() -> void:
    assert(item.get_texture() == null)
    var item2 := inventory.create_and_add_item("item1")
    assert(item2.get_texture() != null)
    assert(item2.get_texture().resource_path == "res://images/item_book_blue.png")


func test_get_title() -> void:
    assert(item.get_title() == "minimal_item")
    var item2 := inventory.create_and_add_item("item1")
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
