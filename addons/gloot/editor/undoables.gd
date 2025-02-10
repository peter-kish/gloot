extends Object

const _Undoables = preload("res://addons/gloot/editor/undoables.gd")


static func _get_undo_redo_manager() -> EditorUndoRedoManager:
    if Engine.is_editor_hint():
        var Gloot = load("res://addons/gloot/gloot.gd")
        if Gloot.instance() == null:
            return null
        var undo_redo_manager = Gloot.instance().get_undo_redo()
        if undo_redo_manager == null:
            return null
        return undo_redo_manager
    else:
        return null


static func _undoable_action_impl(objects: Array, action_name: String, callable: Callable) -> bool:
    var undo_redo_manager = _get_undo_redo_manager()
    if undo_redo_manager == null:
        return callable.call()

    var old_states := _serialize_objects(objects)
    var result: bool = callable.call()
    if !result:
        return false
    var new_states := _serialize_objects(objects)

    undo_redo_manager.create_action(action_name)
    undo_redo_manager.add_do_method(_Undoables, "_deserialize_objects", objects, new_states)
    undo_redo_manager.add_undo_method(_Undoables, "_deserialize_objects", objects, old_states)
    undo_redo_manager.commit_action()

    return true


static func _deserialize_objects(objects: Array, object_data: Array[Dictionary]) -> void:
    assert(objects.size() == object_data.size())
    for i in range(objects.size()):
        if objects[i].has_method("_deserialize_undoable"):
            objects[i]._deserialize_undoable(object_data[i])
        elif objects[i].has_method("deserialize"):
            objects[i].deserialize(object_data[i])


static func _serialize_objects(objects: Array) -> Array[Dictionary]:
    var result: Array[Dictionary]
    for object in objects:
        if object.has_method("_serialize_undoable"):
            result.push_back(object._serialize_undoable())
        elif object.has_method("serialize"):
            result.push_back(object.serialize())
    return result


static func undoable_action(object: Variant, action_name: String, callable: Callable) -> bool:
    if typeof(object) == TYPE_ARRAY:
        return _undoable_action_impl(object, action_name, callable)
    return _undoable_action_impl([object], action_name, callable)
