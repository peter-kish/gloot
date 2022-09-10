extends TestSuite

const Verify = preload("res://addons/gloot/verify.gd")

var d: Dictionary = {
    "f": 3.14,
    "i": 3,
    "s": "foobar",
    "a": [1, 2, 3]
}


func init_suite():
    tests = ["test_mandatory", "test_optional"]


func test_mandatory() -> void:
    assert(Verify.dict(d, true, "f", TYPE_REAL))
    assert(Verify.dict(d, true, "i", TYPE_INT))
    assert(Verify.dict(d, true, "s", TYPE_STRING))
    assert(Verify.dict(d, true, "a", TYPE_ARRAY, TYPE_INT))


func test_optional() -> void:
    assert(Verify.dict(d, false, "f_optional", TYPE_REAL))
    assert(Verify.dict(d, false, "i_optional", TYPE_INT))
    assert(Verify.dict(d, false, "s_optional", TYPE_STRING))
    assert(Verify.dict(d, false, "a_optional", TYPE_ARRAY, TYPE_INT))