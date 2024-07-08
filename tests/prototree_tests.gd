extends TestSuite

const TEST_PROTOTYPE_NAME = "test_prototype"
const TEST_ABS_PROTOTYPE_PATH = "/test_prototype"
const TEST_PROPERTY_NAME = "test_property"
const TEST_PROPERTY_NAME2 = "test_property2"
const TEST_RELATIVE_PATH = "one/two/three"
const TEST_ABSOLUTE_PATH = "/one/two/three"


func init_suite() -> void:
    tests = [
        "constructor_test",
        "child_prototypes_test",
        "properties_test",
        "prototree_test",
        "prototype_path_test",
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

    assert(new_prototype.get_prototype(TEST_ABS_PROTOTYPE_PATH) == new_prototype)

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
    assert(prototree.has_prototype_property("/%s" % TEST_PROTOTYPE_NAME, TEST_PROPERTY_NAME))
    assert(prototree.get_prototype_property("/%s" % TEST_PROTOTYPE_NAME, TEST_PROPERTY_NAME) == 42)


func prototype_path_test() -> void:
    var path := PrototypePath.new(TEST_RELATIVE_PATH)
    assert(path.get_name_count() == 3)
    assert(path.get_name(0) == "one")
    assert(path.get_name(1) == "two")
    assert(path.get_name(2) == "three")
    assert(str(path) == TEST_RELATIVE_PATH)
    assert(!path.is_absolute())

    var path2 := PrototypePath.new(TEST_ABSOLUTE_PATH)
    assert(path2.get_name_count() == 3)
    assert(path2.get_name(0) == "one")
    assert(path2.get_name(1) == "two")
    assert(path2.get_name(2) == "three")
    assert(str(path2) == TEST_ABSOLUTE_PATH)
    assert(path2.is_absolute())

    var prototype := Prototype.new(TEST_PROTOTYPE_NAME)
    var new_prototype := prototype.create_prototype(TEST_PROTOTYPE_NAME)
    var prototype_path := prototype.get_path()
    var new_prototype_path := new_prototype.get_path()
    assert(str(prototype_path) == "/")
    assert(str(new_prototype_path) == ("/%s" % TEST_PROTOTYPE_NAME))

    assert(PrototypePath.str_paths_equal("one/two/three", "  one// two /three "))
    assert(PrototypePath.new("one/two/three").equal(PrototypePath.new("  one// two /three ")))


func deserialize_test() -> void:
    var prototree := ProtoTree.new()
    assert(prototree.deserialize(preload("res://tests/data/protoset_basic.json")))
    assert(!prototree.is_empty())
    assert(prototree.get_root().has_prototype("item1"))
    var item1 := prototree.get_root().get_prototype("item1")
    assert(item1.get_property("name") == "item 1")
    assert(item1.get_property("image") == "res://images/item_book_blue.png")
