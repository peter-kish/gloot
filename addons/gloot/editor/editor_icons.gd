static func get_icon(editor_interface: EditorInterface, icon_name: String) -> Texture:
    if editor_interface:
        var gui = editor_interface.get_base_control()
        var icon = gui.get_icon(icon_name, "EditorIcons")
        return icon

    return null