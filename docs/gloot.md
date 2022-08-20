# `GLoot`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Auto loaded singleton GLoot class that contains globally accessible GLoot functionality. For now the global GLoot API consists of only one signal.

## Signals

* `item_dropped(item: InventoryItem, global_position: Vector2)` - Emitted when an item has been dragged and dropped outside of a `CtrlInventoryGrid`.
