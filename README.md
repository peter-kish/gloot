# GLoot

<p align="center">
  <img src="images/gloot_logo_128x128.png" />
</p>

A universal inventory system for the Godot game engine (version 4.2 and newer).

## Table of Contents

1. [Features](#features)
    1. [Inventory Item Class](#inventory-item-class)
    2. [Item Prototypes and Prototrees](#item-prototypes-and-prototrees)
    3. [Inventory Class](#inventory-class)
    4. [Inventory Constraints](#inventory-constraints)
    5. [Item Slots](#item-slots)
    6. [UI Controls](#ui-controls)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Creating Item Prototypes](#creating-item-prototypes)
    1. [Minimal Prototree](#minimal-prototree)
    2. [`stack_size` and `max_stack_size`](#stack_size-and-max_stack_size)
    3. [Prototrees with Grid Constraint Properties](#prototrees-with-grid-constraint-properties)
    4. [Prototrees with Weight Constraint Properties](#prototrees-with-weight-constraint-properties)
    5. [Prototype Inheritance](#prototype-inheritance)
    6. [Editing Item Properties](#editing-item-properties)
5. [Serialization](#serialization)
6. [Documentation](#documentation)

## Features

### Inventory Item Class
The `InventoryItem` class represents an item stack. All item stacks have a default stack size (and maximum stack size) of 1. Items can have properties that are based on item prototypes from a prototype tree.

### Item Prototypes and Prototrees

Prototypes define common properties for inventory items. Items based on a prototype have the same properties as the prototype. They can also override some of those properties or define completely new ones that are not present in the prototype.

Prototypes can inherit other prototypes, forming a tree-like structure, i.e. a `Prototree`. Prototrees are defined in JSON format and are stored as a JSON resource.

### Inventory Class
The `Inventory` class represents a basic inventory. Supports basic inventory operations (adding, removing, transferring items etc.) and can be configured by adding various inventory constraints.

### Inventory Constraints
* `GridConstraint` - Limits the inventory to a 2d grid of a given width and height.
* `WeightConstraint` - Limits the inventory to a given weight capacity (the default unit weight of an item is 1).
* `ItemCountConstraint` - Limits the inventory to a given item count.

### Item Slots
* `ItemSlot` - Can hold one inventory item.

### UI Controls
User interfaces are usually unique for each project, but it often helps to have some basic UI elements ready for earlier development phases and testing.
The following controls offer some basic interaction with various inventories:
* `CtrlInventory` - Control node for displaying inventories as an `ItemList`.
* `CtrlInventoryCapacity` - Control node for displaying inventory capacity (in case a `WeightConstraint` or a `ItemCountConstraint` is attached to the inventory) as a progress bar.
* `CtrlInventoryGrid` - Control node for displaying inventories with a `GridConstraint` on a 2d grid.
* `CtrlItemSlot` - A control node representing an inventory slot (`ItemSlot`).

## Installation

1. Create an `addons` directory inside your project directory.
2. Get the plugin from the AssetLib or from GitHub
    * From the AssetLib: Open the AssetLib from the Godot editor and search for "GLoot". Click download and deselect everything except the `addons` directory when importing.
    * From GitHub: Run `git clone https://github.com/peter-kish/gloot.git` and copy the contents of the `addons` directory to your projects `addons` directory.
4. Enable the plugin in `Project Settings > Plugins`.

## Usage

1. Create an `Prototree` resource that will hold all the item prototypes used by the inventory (see [Creating Item Prototypes]() below).
2. Create an `Inventory` node in your scene and set its `prototree_json` property (previously created).
3. (*Optional*) Add constraints as child nodes to the previously created inventory node.
3. Add items to the inventory from the inspector:
    Items can also be added from code, e.g. by calling `create_and_add_item()` to create and add items based on the given prototype ID:
4. (*Optional*) Create item slots that will hold various items (for example the currently equipped weapon or armor).
5. Create some UI controls to display the created inventory and its contents.
6. Call `add_item()`, `remove_item()` etc. from your scripts to manipulate inventory nodes. Refer to the documentation for more details about the available properties, methods and signals for each class.

## Creating Item Prototypes

An item prototype is a set of item properties that all items based on that prototype will contain. Items based on a specific prototype can override these properties or add new properties that are not defined in the prototype.

Prototypes can inherit other prototypes, forming a tree-like structure, i.e. a `Prototree`. An item prototype is defined by its path in the prototree and its properties.

### Minimal Prototree

Prototrees are defined as JSON resources. The prototree is defined as a JSON object representing the root prototype. Prototypes consist of two JSON objects (both are optional):
1. `prototypes` - Contains the child prototypes
2. `properties` - Contains the prototype properties

Below is an example of a minimal prototree in JSON format:
```javascript
{
    // The root prototype has only one prototype and no properties:
    "prototypes": {
        // "minimal_item" has no child prototypes and no properties:
        "minimal_item": {
        }
    }
}
```

This prototree only contains one prototype named `minimal_item`, which has no properties.

### `stack_size` and `max_stack_size`

To define the stack size of an item prototype, use the `stack_size` property. If not defined, the stack size will be 1. Some GLoot functions that work with item stacks (e.g. `Inventory.split_stack` or `InventoryItem.split`) will manipulate this property.

Similar to `stack_size`, the `max_stack_size` defines the maximum stack size and its default value is 1.

Example:
```javascript
{
    "prototypes": {
        // The default stack size and the default maximum stack size is 1:
        "watch": {},
        // A full deck of 52 cards:
        "deck_of_cards": {
            "properties": {
                "stack_size": 52,
                "max_stack_size": 52
            }
        },
        // Half a magazine of bullets:
        "pistol_bullets": {
            "properties": {
                "stack_size": 12,
                "max_stack_size": 24
            }
        }
    }
}
```

### Prototrees with Grid Constraint Properties

A `GridConstraint` can interpret the following item properties:
* `size` (`Vector2i`) - Defines the width and height of the item. If not defined, the item size is `Vector2i(1, 1)`.
* `rotated` (`bool`) - If `true`, the item is rotated by 90 degrees. If not defined, the item is not rotated.
* `positive_rotation` (`bool`) - Indicates whether the item icon will be rotated by positive or negative 90 degrees. If not defined, the item is rotated by positive 90 degrees.

Example:
```javascript
{
    "prototypes": {
        // The default item size is Vector2i(1, 1):
        "1x1_knife": {},
        // Rotate the spear to position it horizontally (size.y becomes its width):
        "1x3_spear": {
            "properties": {
                "size": "Vector2i(1, 3)",
                "rotated": "true"
            }
        },
        "2x2_bomb": {
            "properties": {
                "size": "Vector2i(2, 2)"
            }
        }
    }
}
```

### Prototrees with Weight Constraint Properties

If an item is inside an inventory with a `WeightConstraint`, its `weight` property is interpreted as the (unit) weight of the item.

Example:
```javascript
{
    "prototypes": {
        // The default item weight is 1 and the default stack size is 1.
        // The total stack weight is 1 * 1 = 1:
        "small_item": {},
        // The total stack weight is 1 * 20 = 20:
        "big_item": {
            "properties": {
                "weight": 20
            }
        },
        // The total stack weight is 10 * 2 = 20:
        "small_stackable_item": {
            "properties": {
                "stack_size": 10,
                "max_stack_size": 10,
                "weight": 2
            }
        }
    }
}
```

### Prototype Inheritance

Prototypes can inherit properties from other prototypes, which can also override some of those properties.

Example:
```javascript
{
    "prototypes": {
        // Base prototype for melee weapons.
        // Defines the "weapon_type" and "damage" properties:
        "melee_weapons": {
            "properties": {
                "weapon_type": "melee",
                "damage": 1
            },
            "prototypes": {
                // Inherits the "weapon_type" property ("melee").
                // Overrides the "damage" property (from 1 to 10):
                "knife": {
                    "properties": {
                        "damage": 10
                    }
                },
                // Inherits the "weapon_type" property ("melee").
                // Overrides the "damage" property (from 1 to 30):
                "axe": {
                    "properties": {
                        "damage": 30
                    }
                }
            }
        }
    }
}
```

### Editing Item Properties

Item properties defined in the prototree JSON resource can be overridden for each individual item using the `set_property()` method and overridden property values can be cleared using the `clear_property()` method:

```gdscript
# Decrease the size of an item stack by 1
var stack_size: int = item.get_property("stack_size")
if stack_size > 0:
    item.set_property("stack_size", stack_size - 1)
```

Item properties can also be modified and overridden using the editor: To open the item properties editor, first select an inventory node.
Then select an item in the inspector and press the "Edit" button.
Properties marked with green color in the item editor represent overridden properties.

## Serialization

All GLoot classes have a `serialize()` and a `deserialize()` method that can be used for serialization. The `serialize()` methods serializes the class into a dictionary, that can be further serialized into JSON, binary or some other format.

Example:
```gdscript
# Serialize the inventory into a JSON string
var inventory: Inventory = get_node("inventory")
var dict: Dictionary = inventory.serialize()
var json: String = JSON.stringify(dict)
```

The `deserialize()` methods receive a dictionary as argument that has been previously generated with `serialize()` and apply the data to the current class instance.

Example:
```gdscript
# Deserialize the inventory from a JSON string
var inventory: Inventory = get_node("inventory")
var res: JSONParseResult = JSON.parse(json)
if res.error == OK:
    var dict = res.result
    inventory.deserialize(dict)
```

## Documentation

The documentation can be found [here](https://github.com/peter-kish/gloot/tree/dev_v3.0.0/docs).