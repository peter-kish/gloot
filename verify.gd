class_name GlootVerify

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


static func dict(dict: Dictionary, mandatory: bool, key: String, value_type: int, array_type: int = -1) -> bool:
    if !dict.has(key):
        if !mandatory:
            return true;
        print("Missing key: '%s'!" % key);
        return false;
    
    var t: int = typeof(dict[key]);
    if t != value_type:
        print("Key '%s' has wrong type! Expected '%s', got '%s'!" % [key, value_type, t]);
        return false;

    if value_type == TYPE_ARRAY && array_type >= 0:
        var array = dict[key];
        for i in range(array.size()):
            if typeof(array[i]) != array_type:
                print("Array element %d has wrong type! Expected '%s', got '%s'!" % [i, array_type, array[i]]);

    return true;
