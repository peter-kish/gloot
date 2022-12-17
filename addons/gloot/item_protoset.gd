class_name ItemProtoset
extends Resource
#@tool

const KEY_ID: String = "id"

@export_multiline var json_data :
	get:
		return json_data
	set(new_json_data):
		json_data = new_json_data
		if !json_data.is_empty():
			parse(json_data)
		emit_changed()

var _prototypes: Dictionary = {} :
	get:
		return _prototypes
	set(new_prototypes):
		print(new_prototypes)
		_prototypes = new_prototypes
		update_json_data()
		emit_changed()


func parse(json: String) -> void:
	_prototypes.clear()

	var test_json_conv = JSON.new()
	test_json_conv.parse(json)
	var parse_result = test_json_conv.get_data()
	assert(parse_result is Array, "JSON file must contain an array!")

	for prototype in parse_result:
		assert(prototype is Dictionary, "Item definition must be a dictionary!")
		assert(prototype.has(KEY_ID), "Item definition must have an '%s' property!" % KEY_ID)
		assert(prototype[KEY_ID] is String, "'%s' property must be a string!" % KEY_ID)

		var id = prototype[KEY_ID]
		assert(!_prototypes.has(id), "Item definition ID '%s' already in use!")
		_prototypes[id] = prototype


func _to_json() -> String:
	var result: Array
	for prototype_id in _prototypes.keys():
		result.append(get(prototype_id))

	# TODO: Add plugin settings for this
	return JSON.stringify(result, "    ")


func update_json_data() -> void:
	json_data = _to_json()
	emit_changed()


func get(id: StringName) -> Variant:
	assert(has(id), "No prototype")
	return _prototypes[id]


func add(id: String) -> void:
	assert(!has(id), "Prototype with ID already exists")
	_prototypes[id] = {KEY_ID: id}
	emit_changed()


func remove_at(id: String) -> void:
	assert(has(id), "No prototype for ID")
	_prototypes.erase(id)
	emit_changed()


func rename(id: String, new_id: String) -> void:
	assert(has(id), "No prototype for ID")
	assert(!has(new_id), "Prototype with ID already exists")
	add(new_id)
	_prototypes[new_id] = _prototypes[id].duplicate()
	_prototypes[new_id][KEY_ID] = new_id
	remove_at(id)
	emit_changed()


func has(id: String) -> bool:
	return _prototypes.has(id)


func get_item_property(id: String, property_name: String, default_value = null) -> Variant:
	print(_prototypes)
	if has(id):
		var prototype = get(id)
		if !prototype.is_empty() && prototype.has(property_name):
			return prototype[property_name]
	
	return default_value
