# Godot Inventory System

An universal inventory system for the Godot game engine (version 3.x and newer).

## Features

### Item Definitions

* ![](images/icon_item_definitions.svg "ItemDefinitions icon") `ItemDefinitions` - A resource type holding an array of inventory item prototypes in JSON format.

### Inventory Items

* ![](images/icon_item.svg "InventoryItem icon") `InventoryItem` - Basic inventory item class. Nameless, weightless and shapeless.
* ![](images/icon_item_stackable.svg "InventoryItemStackable icon") `InventoryItemStackable` - Represents a stack of inventory items. Item stacks can be split up and joined together. The total weight of a stack equals its size multiplied by the unit weight of the item. Inherits InventoryItem.
* ![](images/icon_item_rect.svg "InventoryItemRect icon") `InventoryItemRect` - Inventory item that takes up a predefined amount of 2d space in a grid-based inventory (see `InventoryGrid` below). The size of the item is defined by its weight and height, while its position is defined by x and y coordinates. Rectangular items can also be rotated by 90 degrees for easier inventory organization. In case the item has been rotated, its width and height values are swapped and its "rotated" flag is set. Inherits InventoryItem.

### Inventory Types

* ![](images/icon_inventory.svg "Inventory icon") `Inventory` - Basic inventory class. Supports basic inventory operations (adding, removing, transferring items etc.). Can contain an unlimited amount of items.
* ![](images/icon_inventory_stacked.svg "InventoryStacked icon") `InventoryStacked` - Contains `InventoryItemStackable` items and has a limited item capacity in terms of weight. Inherits Inventory.
* ![](images/icon_inventory_grid.svg "InventoryGrid icon") `InventoryGrid` - Contains `InventoryItemRect` items and has a limited capacity in terms of space. The inventory capacity is defined by its width and height. Inherits Inventory.

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

1. Create an `ItemDefinitions` resource that will hold all the item prototypes used by the inventory. The resource has a single property `json_data` that holds all item prototype information in JSON format.
2. Create an inventory node in your scene. Set its capacity if needed (required for `InventoryStacked` and `InventoryGrid`) and set its `item_definitions` property (previously created).
3. To add items to the inventory set its `contents` property. List the prototype IDs of the items that you want added to the inventory.
    **NOTE**: Pay attention to the inventory capacity to avoid assertions when the scene is loaded.
4. (*Optional*) Create item slots that will hold various items (for example the currently equipped weapon or armor).
5. Create some UI controls to display the created inventory and its contents.
6. Call `add_item()`, `remove_item()`, `transfer_item()` etc. from your scripts to move items around multiple inventory nodes. Refer to the class diagrams for more details about the available properties, methods and signals for each class.

## Creating Item Definitions

TODO:
* Minimal item definitions JSON
* Item definitions for `InventoryStacked`
* Item definitions for `InventoryGrid`
* Custom prototype fields

## Extending Functionality

TODO:
* Inheriting from InventoryItem
* Inheriting from Inventory

## The API

TODO

## Class Diagrams

![InventoryItem class diagram](images/cd_inventory_item.png "InventoryItem class diagram")

![Inventory class diagram](images/cd_inventory.png "Inventory class diagram")

![ItemSlot class diagram](images/cd_item_slot.png "ItemSlot class diagram")

![ItemDefinitions class diagram](images/cd_item_definitions.png "ItemDefinitions class diagram")

## Examples

Take a look at the `examples` directory for some example scenes:
* `inventory_transfer.tscn` - Displaying two basic inventories (`Inventory`) and transferring items between them.
* `inventory_stacked_transfer.tscn` - Displaying two stack based inventories (`InventoryStacked`) and transferring items between them.
* `inventory_grid_transfer.tscn` - Displaying two grid based inventories (`InventoryGrid`) and transferring items between them using drag and drop.