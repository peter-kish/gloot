static func safe_connect(s: Signal, c: Callable) -> void:
    if !s.is_connected(c):
        s.connect(c)


static func safe_disconnect(s: Signal, c: Callable) -> void:
    if s.is_connected(c):
        s.disconnect(c)
