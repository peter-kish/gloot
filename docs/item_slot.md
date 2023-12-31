# `ItemSlot`

Inherits: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Holds an inventory item.

## Properties

* `item_protoset: ItemProtoset` - An `ItemProtoset` resource containing item prototypes that the slot can receive.

## Methods

* `equip(item: InventoryItem, return_item_to_source_inventory: bool) -> bool` - Equips the given inventory item in the slot. If the slot already contains an item, `clear(return_item_to_source_inventory)` will be called first. Returns `false` if the `clear` call fails, the slot can't hold, or already holds the given item. Returns `true` otherwise.
* `clear(return_item_to_source_inventory: bool) -> bool` - Clears the item slot. If `return_item_to_source_inventory` is `true`, the method will try to return the item to its original inventory. Returns `false` if the item can't be returned, or if the slot is already empty.
    > Note: this method will not free the item if `return_item_to_source_inventory` is `false`.
* `can_hold_item(new_item: InventoryItem) -> bool` - Checks if the slot can hold the given item, i.e. the item has the same protoset as the slot and is not `null`. This method can be overridden to implement item slots that can only hold specific items.
* `reset()` - Clears the item slot and queues the contained item (if any) for deletion.
* `serialize() -> Dictionary` - Serializes the item slot into a dictionary.
* `deserialize(source: Dictionary) -> bool` - Loads the item slot data from the given dictionary. 
    > Note: If the slot contains an item prior to deserialization, it will be queued for deletion.

## Signals

* `item_equipped()` - Emitted when an item is placed in the slot.
* `item_cleared()` - Emitted when the slot is cleared.
* `protoset_changed()` - Emitted when the `item_protoset` property has been changed.