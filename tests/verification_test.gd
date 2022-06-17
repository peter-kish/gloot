extends Test


func run_tests():
    var d: Dictionary = {
        "f": 3.14,
        "i": 3,
        "s": "foobar",
        "a": [1, 2, 3]
    }

    assert(GlootVerify.dict(d, "f", TYPE_REAL));
    assert(GlootVerify.dict(d, "i", TYPE_INT));
    assert(GlootVerify.dict(d, "s", TYPE_STRING));
    assert(GlootVerify.dict(d, "a", TYPE_ARRAY, TYPE_INT));