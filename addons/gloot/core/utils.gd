static func safe_connect(s: Signal, c: Callable) -> void:
    if !s.is_connected(c):
        s.connect(c)


static func safe_disconnect(s: Signal, c: Callable) -> void:
    if s.is_connected(c):
        s.disconnect(c)

static func str_to_var(s: String) -> Variant:
    var variant = str_to_var(s)
    # str_to_var considers all strings that start with a digit convertable to
    # int/float (which is not consistent with String.is_valid_int and
    # String.is_valid_float).
    if typeof(variant) == TYPE_INT && !s.is_valid_int():
        variant = null
    if typeof(variant) == TYPE_FLOAT && !s.is_valid_float():
        variant = null
    return variant
