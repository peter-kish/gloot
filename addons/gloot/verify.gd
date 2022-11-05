
const type_names: Array = [
    "null",
    "bool",
    "int",
    "float",
    "String",
    "Vector2",
    "Rect2",
    "Vector3",
    "Transform2D",
    "Plane",
    "Quat",
    "AABB",
    "Basis",
    "Transform",
    "Color",
    "NodePath",
    "RID",
    "Object",
    "Dictionary",
    "Array",
    "PoolByteArray",
    "PoolIntArray",
    "PoolRealArray",
    "PoolStringArray",
    "PoolVector2Array",
    "PoolVector3Array",
    "PoolColorArray"
]


static func create_var(type: int):
    match type:
        TYPE_BOOL:
            return false
        TYPE_INT:
            return 0
        TYPE_REAL:
            return 0.0
        TYPE_STRING:
            return ""
        TYPE_VECTOR2:
            return Vector2()
        TYPE_RECT2:
            return Rect2()
        TYPE_VECTOR3:
            return Vector3()
        TYPE_TRANSFORM2D:
            return Transform2D()
        TYPE_PLANE:
            return Plane()
        TYPE_QUAT:
            return Quat()
        TYPE_AABB:
            return AABB()
        TYPE_BASIS:
            return Basis()
        TYPE_TRANSFORM:
            return Transform()
        TYPE_COLOR:
            return Color()
        TYPE_NODE_PATH:
            return NodePath()
        TYPE_RID:
            return RID()
        TYPE_OBJECT:
            return Object()
        TYPE_DICTIONARY:
            return {}
        TYPE_ARRAY:
            return []
        TYPE_RAW_ARRAY:
            return PoolByteArray()
        TYPE_INT_ARRAY:
            return PoolIntArray()
        TYPE_REAL_ARRAY:
            return PoolRealArray()
        TYPE_STRING_ARRAY:
            return PoolStringArray()
        TYPE_VECTOR2_ARRAY:
            return PoolVector2Array()
        TYPE_VECTOR3_ARRAY:
            return PoolVector3Array()
        TYPE_COLOR_ARRAY:
            return PoolColorArray()
    return null


static func dict(dict: Dictionary,
        mandatory: bool,
        key: String,
        expected_value_type,
        expected_array_type: int = -1) -> bool:

    if !dict.has(key):
        if !mandatory:
            return true
        print("Missing key: '%s'!" % key)
        return false
    
    if expected_value_type is int:
        return _check_dict_key_type(dict, key, expected_value_type, expected_array_type)
    elif expected_value_type is Array:
        return _check_dict_key_type_multi(dict, key, expected_value_type)

    print("Warning: 'value_type' must be either int or Array!")
    return false


static func _check_dict_key_type(dict: Dictionary,
        key: String,
        expected_value_type: int,
        expected_array_type: int = -1) -> bool:

    var t: int = typeof(dict[key])
    if t != expected_value_type:
        print("Key '%s' has wrong type! Expected '%s', got '%s'!" %
            [key, type_names[expected_value_type], type_names[t]])
        return false

    if expected_value_type == TYPE_ARRAY && expected_array_type >= 0:
        return _check_dict_key_array_type(dict, key, expected_array_type)

    return true


static func _check_dict_key_array_type(dict: Dictionary, key: String, expected_array_type: int):
    var array: Array = dict[key]
    for i in range(array.size()):
        if typeof(array[i]) != expected_array_type:
            print("Array element %d has wrong type! Expected '%s', got '%s'!" %
                [i, type_names[expected_array_type], type_names[array[i]]])
            return false

    return true

            
static func _check_dict_key_type_multi(dict: Dictionary,
        key: String,
        expected_value_types: Array) -> bool:

    var t: int = typeof(dict[key])
    if !(t in expected_value_types):
        print("Key '%s' has wrong type! Got '%s', but expected one of the following:" %
            [key, type_names[t]])
        for expected_type in expected_value_types:
            print("  %s" % type_names[expected_type])
        return false

    return true


static func vector_positive(v: Vector2) -> bool:
    return v.x >= 0 && v.y >= 0


static func rect_positive(rect: Rect2) -> bool:
    return vector_positive(rect.position) && vector_positive(rect.size)
