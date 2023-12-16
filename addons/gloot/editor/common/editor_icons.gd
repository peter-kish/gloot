@tool

static func get_icon(icon_name: String) -> Texture2D:
    var gui = EditorInterface.get_base_control()
    var icon = gui.get_theme_icon(icon_name, "EditorIcons")
    return icon
