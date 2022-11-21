extends Node

signal item_grabbed(item)
signal item_dropped(item, position)
signal grab_canceled(item)

var _grabbed_inventory_item: Node
var _grab_offset: Vector2
