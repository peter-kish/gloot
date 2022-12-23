static func get_icon(editor_interface: EditorInterface, icon_name: String) -> Texture2D:
    if editor_interface:
        var gui = editor_interface.get_base_control()
        var icon = gui.get_theme_icon(icon_name, "EditorIcons")
        return icon

    return null
