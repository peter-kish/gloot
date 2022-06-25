# `ItemPrototype`

Inherits: N/A, JSON

## Description

The prototype data for a given item's definition. These prototypes are expandable and can contain game data, such as item weights, sizes, resource paths, and more. The most barebones format for a single item prototype is the following JSON:

```json
    {
        "id": "minimal_item"
    }
```

An array of `ItemPrototype`s are utilized inside an [`ItemProtoset`](./item_protoset.md)

## Properties

**Required**

* `id: string` - A string identifier. Must be unique across all item prototypes.

**Optional**

* `name: string` - The name of the item as displayed inside controls.
* `image: string` - A resource path to a texture to use as the item's image inside controls. Example: `"image": "res://assets/image.png"`
* `stack_size: int` - Defines the default stack size of the item. Newly created items that use this prototype will have this stack size. Has the value of 1 if not defined.
* `weight: float` - Defines the unit weight of the item. Has the value of 1.0 if not defined. NOTE: The total weight of an item is defined as its unit weight multiplied by its stack size.
* `width: int` - Defines the width of the item. Has the value of 1 if not defined.
* `height: int` - Defines the height of the item. Has the value of 1 if not defined.

The following properties will be used by InventoryStacked: `['image', 'name', 'stack_size', 'weight']`
The following properties will be used by InventoryGrid: `['image', 'width', 'height']`

In addition to the properties listed above, you can add any bespoke properties for your project's specific needs. See [`InventoryItem`](./inventory_item.md) for usage.
