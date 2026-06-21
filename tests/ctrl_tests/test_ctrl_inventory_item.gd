@tool
extends Node2D


func _ready() -> void:
    %CtrlInventoryItem.item = InventoryItem.new(preload("res://tests/data/protoset_grid.json"), "item_2x2")
