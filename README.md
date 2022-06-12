# Godot Inventory System

An universal inventory system for the Godot game engine (version 3.x and newer).

## Features

### Item Prototypes

* ![](images/icon_item_protoset.svg "ItemProtoset icon") `ItemProtoset` - A resource type holding a set of inventory item prototypes in JSON format.

### Inventory Items

* ![](images/icon_item.svg "InventoryItem icon") `InventoryItem` - Inventory item class. It is based on an item prototype from an `ItemProtoset` resource. Can hold additional properties.

### Inventory Types

* ![](images/icon_inventory.svg "Inventory icon") `Inventory` - Basic inventory class. Supports basic inventory operations (adding, removing, transferring items etc.). Can contain an unlimited amount of items.
* ![](images/icon_inventory_stacked.svg "InventoryStacked icon") `InventoryStacked` - Has a limited item capacity in terms of weight. Inherits Inventory.
* ![](images/icon_inventory_grid.svg "InventoryGrid icon") `InventoryGrid` - Has a limited capacity in terms of space. The inventory capacity is defined by its width and height. Inherits Inventory.

### Item Slots

* ![](images/icon_item_slot.svg "ItemSlot icon") `ItemSlot` - Holds a reference to a given item from a given inventory. The slot can be cleared or bound to one item at a time. In case the item is removed from the inventory or the slot is bound to a different inventory, the slot is automatically cleared.

### UI Controls

* ![](images/icon_ctrl_inventory.svg "CtrlInventory icon") `CtrlInventory` - UI control representing a basic `Inventory`. Displays a list of items in the inventory.
* ![](images/icon_ctrl_inventory_stacked.svg "CtrlInventoryStacked icon") `CtrlInventoryStacked` - UI control representing a stack based inventory (`InventoryStacked`). It lists the contained items and shows an optional progress bar displaying the capacity and fullness of the inventory.
* ![](images/icon_ctrl_inventory_grid.svg "CtrlInventoryGrid icon") `CtrlInventoryGrid` - UI control representing a grid based inventory (`InventoryGrid`). Displays a grid based on the inventory capacity (width and height) and the contained items on the grid. The items can be moved around in the inventory by dragging.

## Installation

1. Create an `addons` directory inside your project directory.
2. Run `git clone` from the `addons` directory.
3. Enable the plugin in `Project Settings > Plugins`.

## Usage

1. Create an `ItemProtoset` resource that will hold all the item prototypes used by the inventory. The resource has a single property `json_data` that holds all item prototype information in JSON format (see *Creating Item Prototypes* below).
2. Create an inventory node in your scene. Set its capacity if needed (required for `InventoryStacked` and `InventoryGrid`) and set its `item_protoset` property (previously created).
3. To add items to the inventory set its `contents` property. List the prototype IDs of the items that you want added to the inventory.
    **NOTE**: Pay attention to the inventory capacity to avoid assertions when the scene is loaded.
4. (*Optional*) Create item slots that will hold various items (for example the currently equipped weapon or armor).
5. Create some UI controls to display the created inventory and its contents.
6. Call `add_item()`, `remove_item()`, `transfer_item()` etc. from your scripts to move items around multiple inventory nodes. Refer to the class diagrams for more details about the available properties, methods and signals for each class.

## Creating Item Prototypes

Item protosets represent a number of item prototypes based on which future inventory items will be created.
An item prototype is defined by its ID and its properties.

### Minimal Item Protoset JSON

There are a few requirements each protoset JSON must fulfill:

* The JSON must be a JSON array.
* Each element of the array must contain the `id` property uniquely identifying the prototype.

Below is an example of a minimal item protoset JSON:

```json
[
    {
        "id": "minimal_item"
    }
]
```

### Item prototypes for a Stack Based Inventory

Prototypes of items contained in stack based inventories support the following additional properties:

* `stack_size` - Defines the default stack size of the item. Newly created items that use this prototype will have this stack size. Has the value of 1 if not defined.
* `weight` - Defines the unit weight of the item. Has the value of 1.0 if not defined.
    **NOTE**: The total weight of an item is defined as its unit weight multiplied by its stack size.

Example:
```json
[
    {
        "id": "stackable_item",
        "stack_size": 10
    },
    {
        "id": "heavy_item",
        "weight": 20.0
    },
    {
        "id": "very_heavy_item",
        "stack_size": 10,
        "weight": 20.0
    }
]
```

The total weight of a `stackable_item` is 10 - The unit weight is not defined and the default value of 1.0 is used. Multiplied with `stack_size` of 10 gives a total weight of 10.0.
The total weight of a `heavy_item` is 20.0 - The stack size is not defined and the default value of 1 is used. Multiplied with `weight` of 20.0 gives a total weight of 20.0.
The total weight of a `very_heavy_item` is 200.0 - The stack size of 10 is multiplied with the unit weight of 20.0.

### Item prototypes for a Grid Based Inventory

Prototypes of items contained in stack based inventories support the following additional properties:

* `width` - Defines the width of the item. Has the value of 1 if not defined.
* `height` - Defines the height of the item. Has the value of 1 if not defined.

Example:
```json
[
    {
        "id": "1x1_knife",
        "width": 1,
        "height": 1
    },
    {
        "id": "1x3_spear",
        "width": 1,
        "height": 3
    },
    {
        "id": "2x2_bomb",
        "width": 2,
        "height": 2
    }
]
```

### Additional Prototype Fields

Apart from the previously mentioned properties, item prototypes can hold all kinds of additional user-defined data. Properties like "name" or "description" are often used and can be easily added alongside the predefined properties.

Example:
```json
[
    {
        "id": "knife_01",
        "weight": "2.0",
        "name": "Kitchen Knife",
        "description": "A knife intended to be used in food preparation."
    }
]
```

Any of the item properties can be accessed from code through the `get_property()` methods of the `InventoryItem` classes:
```
var item_name = item.get_property("name", "")
var item_description = item.get_property("description", "")
```

### Editing item properties

Item properties defined in the `ItemProtoset` resource can be overridden for each individual item using the `set_property()` method and overridden property values can be cleared using the `clear_property()` method:
```
# Decrease the size of an item stack by 1
var stack_size: int = item.get_property("stack_size")
if stack_size > 0:
    item.set_property("stack_size", stack_size - 1)
```

## The API

TODO

## Class Diagrams

![InventoryItem class diagram](images/cd_inventory_item.png "InventoryItem class diagram")

![Inventory class diagram](images/cd_inventory.png "Inventory class diagram")

![ItemSlot class diagram](images/cd_item_slot.png "ItemSlot class diagram")

![ItemProtoset class diagram](images/cd_item_protoset.png "ItemProtoset class diagram")

## Examples

Take a look at the `examples` directory for some example scenes:
* `inventory_transfer.tscn` - Displaying two basic inventories (`Inventory`) and transferring items between them.
* `inventory_stacked_transfer.tscn` - Displaying two stack based inventories (`InventoryStacked`) and transferring items between them.
* `inventory_grid_transfer.tscn` - Displaying two grid based inventories (`InventoryGrid`) and transferring items between them using drag and drop.