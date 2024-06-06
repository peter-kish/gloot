@tool
extends Node2D


func _ready():
    %CtrlInventoryItem.item = InventoryItem.new(preload("res://tests/data/prototree_grid.json"), "item_2x2")


