extends TestSuite

var inventory: Inventory
var item: InventoryItem

const TEST_PROTOSET = preload("res://tests/data/item_definitions_basic.tres")

func init_suite() -> void:
    tests = [
        "test_get_inventory",
        "test_get_property",
        "test_set_property",
        "test_clear_property",
        "test_reset",
        "test_get_texture",
        "test_get_title",
        "test_serialize",
        "test_serialize_json",
    ]


func init_test() -> void:
    inventory = create_inventory(TEST_PROTOSET)
    item = inventory.create_and_add_item("minimal_item")


func cleanup_test() -> void:
    free_inventory(inventory)
    free_item(item)


func test_get_inventory() -> void:
    assert(item.get_inventory() == inventory)
    inventory.remove_item(item)
    assert(item.get_inventory() == null)


func test_get_property() -> void:
    assert(item.get_property("name", "none") == "none")
    item.prototype_id = "item1"
    assert(item.get_property("name", "none") == "item 1")


func test_set_property() -> void:
    item.set_property("name", "Bob")
    assert(item.get_property("name") == "Bob")


func test_clear_property() -> void:
    item.set_property("name", "Bob")
    item.clear_property("name")
    assert(item.get_property("name", "none") == "none")

    item.prototype_id = "item1"
    item.set_property("name", "Bob")
    assert(item.get_property("name", "none") == "Bob")
    item.clear_property("name")
    assert(item.get_property("name", "none") == "item 1")


func test_reset() -> void:
    item.set_property("foo", "bar")

    item.reset()
    assert(item.protoset == inventory.item_protoset)
    assert(item.prototype_id == "minimal_item")
    assert(item.properties.is_empty())
    assert(!item.properties.has("foo"))

    inventory.remove_item(item)
    item.reset()
    assert(item.protoset == null)
    assert(item.prototype_id == "")
    assert(item.properties.is_empty())


func test_get_texture() -> void:
    assert(item.get_texture() == null)
    item.prototype_id = "item1"
    assert(item.get_texture() != null)
    assert(item.get_texture().resource_path == "res://images/item_book_blue.png")


func test_get_title() -> void:
    assert(item.get_title() == "minimal_item")
    item.prototype_id = "item1"
    assert(item.get_title() == "item 1")


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

