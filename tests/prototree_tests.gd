extends TestSuite

const TEST_PROTOTYPE_NAME = "test_prototype"
const TEST_PROPERTY_NAME = "test_property"
const TEST_PROPERTY_NAME2 = "test_property2"


func init_suite() -> void:
    tests = [
        "constructor_test",
        "child_prototypes_test",
        "properties_test",
        "prototree_test",
        "deserialize_test",
    ]


func constructor_test() -> void:
    var prototype = Prototype.new(TEST_PROTOTYPE_NAME)
    assert(prototype.get_id() == TEST_PROTOTYPE_NAME)


func child_prototypes_test() -> void:
    var prototype = Prototype.new(TEST_PROTOTYPE_NAME)
    assert(!prototype.has_prototype(TEST_PROTOTYPE_NAME))
    assert(prototype.get_prototypes().is_empty())

    var new_prototype = prototype.create_prototype(TEST_PROTOTYPE_NAME)
    assert(prototype.has_prototype(TEST_PROTOTYPE_NAME))
    assert(prototype.get_prototype(TEST_PROTOTYPE_NAME) == new_prototype)
    assert(prototype.get_prototypes().hash() == [new_prototype].hash())

    prototype.remove_prototype(TEST_PROTOTYPE_NAME)
    assert(!prototype.has_prototype(TEST_PROTOTYPE_NAME))
    assert(prototype.get_prototypes().is_empty())


func properties_test() -> void:
    var prototype = Prototype.new(TEST_PROTOTYPE_NAME)
    assert(!prototype.has_property(TEST_PROPERTY_NAME))

    prototype.set_property(TEST_PROPERTY_NAME, 42)
    assert(prototype.has_property(TEST_PROPERTY_NAME))
    assert(prototype.get_property(TEST_PROPERTY_NAME) == 42)

    var new_prototype = prototype.create_prototype(TEST_PROTOTYPE_NAME)
    assert(new_prototype.has_property(TEST_PROPERTY_NAME))
    assert(new_prototype.get_property(TEST_PROPERTY_NAME) == 42)
    new_prototype.set_property(TEST_PROPERTY_NAME, 43)
    assert(new_prototype.get_property(TEST_PROPERTY_NAME) == 43)

    new_prototype.set_property(TEST_PROPERTY_NAME2, Vector2i.ONE)
    assert(prototype.get_properties().hash() == {TEST_PROPERTY_NAME: 42}.hash())
    assert(
        new_prototype.get_properties().hash() ==
        {
            TEST_PROPERTY_NAME: 43,
            TEST_PROPERTY_NAME2: Vector2i.ONE,
        }.hash()
    )


func prototree_test() -> void:
    var prototree = ProtoTree.new()
    assert(prototree.is_empty())
    assert(prototree.get_root().get_id() == "ROOT")

    var prototype := prototree.create_prototype(TEST_PROTOTYPE_NAME)
    prototype.set_property(TEST_PROPERTY_NAME, 42)
    assert(prototree.has_prototype_property(TEST_PROTOTYPE_NAME, TEST_PROPERTY_NAME))
    assert(prototree.get_prototype_property(TEST_PROTOTYPE_NAME, TEST_PROPERTY_NAME) == 42)


func deserialize_test() -> void:
    var prototree := ProtoTree.new()
    assert(prototree.deserialize(preload("res://tests/data/protoset_basic.json")))
    assert(!prototree.is_empty())
    assert(prototree.get_root().has_prototype("item1"))
    var item1 := prototree.get_root().get_prototype("item1")
    assert(item1.get_property("name") == "item 1")
    assert(item1.get_property("image") == "res://images/item_book_blue.png")
