@tool

const Gloot = preload("res://addons/gloot/gloot.gd")

static func get_icon(icon_name: String) -> Texture2D:
    assert(Gloot.instance())
    var editor_interface = Gloot.instance().get_editor_interface()
    if editor_interface:
        var gui = editor_interface.get_base_control()
        var icon = gui.get_theme_icon(icon_name, "EditorIcons")
        return icon

    return null
