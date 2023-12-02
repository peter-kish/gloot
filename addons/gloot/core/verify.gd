
const type_names: Array = [
    "null",
    "bool",
    "int",
    "float",
    "String",
    "Vector2",
    "Vector2i",
    "Rect2",
    "Rect2i",
    "Vector3",
    "Vector3i",
    "Transform2D",
    "Vector4",
    "Vector4i",
    "Plane",
    "Quaternion",
    "AABB",
    "Basis",
    "Transform3D",
    "Projection",
    "Color",
    "StringName",
    "NodePath",
    "RID",
    "Object",
    "Callable",
    "Signal",
    "Dictionary",
    "Array",
    "PackedByteArray",
    "PackedInt32Array",
    "PackedInt64Array",
    "PackedFloat32Array",
    "PackedFloat64Array",
    "PackedStringArray",
    "PackedVector2Array",
    "PackedVector3Array",
    "PackedColorArray"
]


static func create_var(type: int):
    match type:
        TYPE_BOOL:
            return false
        TYPE_INT:
            return 0
        TYPE_FLOAT:
            return 0.0
        TYPE_STRING:
            return ""
        TYPE_VECTOR2:
            return Vector2()
        TYPE_VECTOR2I:
            return Vector2i()
        TYPE_RECT2:
            return Rect2()
        TYPE_RECT2I:
            return Rect2i()
        TYPE_VECTOR3:
            return Vector3()
        TYPE_VECTOR3I:
            return Vector3i()
        TYPE_VECTOR4:
            return Vector4()
        TYPE_VECTOR4I:
            return Vector4i()
        TYPE_TRANSFORM2D:
            return Transform2D()
        TYPE_PLANE:
            return Plane()
        TYPE_QUATERNION:
            return Quaternion()
        TYPE_AABB:
            return AABB()
        TYPE_BASIS:
            return Basis()
        TYPE_TRANSFORM3D:
            return Transform3D()
        TYPE_PROJECTION :
            return Projection()
        TYPE_COLOR:
            return Color()
        TYPE_STRING_NAME:
            return ""
        TYPE_NODE_PATH:
            return NodePath()
        TYPE_RID:
            return RID()
        TYPE_OBJECT:
            return Object.new()
        TYPE_DICTIONARY:
            return {}
        TYPE_ARRAY:
            return []
        TYPE_PACKED_BYTE_ARRAY:
            return PackedByteArray()
        TYPE_PACKED_INT32_ARRAY:
            return PackedInt32Array()
        TYPE_PACKED_INT64_ARRAY:
            return PackedInt64Array()
        TYPE_PACKED_FLOAT32_ARRAY:
            return PackedFloat32Array()
        TYPE_PACKED_FLOAT64_ARRAY:
            return PackedFloat64Array()
        TYPE_PACKED_STRING_ARRAY:
            return PackedStringArray()
        TYPE_PACKED_VECTOR2_ARRAY:
            return PackedVector2Array()
        TYPE_PACKED_VECTOR3_ARRAY:
            return PackedVector3Array()
        TYPE_PACKED_COLOR_ARRAY:
            return PackedColorArray()
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


static func vector_positive(v) -> bool:
    assert(v is Vector2 || v is Vector2i, "v must be a Vector2 or a Vector2i!")
    return v.x >= 0 && v.y >= 0


static func rect_positive(rect: Rect2) -> bool:
    return vector_positive(rect.position) && vector_positive(rect.size)
