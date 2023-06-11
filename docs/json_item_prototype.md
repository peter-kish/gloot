# `Item Prototype`

Type: JSON

## Description

The prototype data for a given item's definition. These prototypes are expandable and can contain game data, such as item weights, sizes, resource paths, and more. The most barebones format for a single item prototype is the following JSON:

```json
    {
        "id": "minimal_item"
    }
```

An array of these `Item Prototype`s are utilized inside an [`Item Protoset (JSON)`](./json_item_protoset.md).

## Properties

**Required**

* `id: string` - A string identifier. Must be unique across all item prototypes.

**Optional**

* `name: string` - The name of the item as displayed inside controls.
* `image: string` - A resource path to a texture to use as the item's image inside controls. Example: `"image": "res://assets/image.png"`
* `stack_size: int` - Defines the default stack size of the item. Newly created items that use this prototype will have this stack size. Has the value of 1 if not defined.
* `max_stack_size: int` - Defines the maximal stack size of the item. Has the value of 100 if not defined.
* `weight: float` - Defines the unit weight of the item. Has the value of 1.0 if not defined. NOTE: The total weight of an item is defined as its unit weight multiplied by its stack size.
* `width: int` - Defines the width of the item. Has the value of 1 if not defined.
* `height: int` - Defines the height of the item. Has the value of 1 if not defined.

The following properties will be used by [`CtrlInventory`](./ctrl_inventory.md): `['image', 'name']`
The following properties will be used by [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md): `['image', 'name', 'stack_size', 'weight']`
The following properties will be used by [`CtrlInventoryGrid`](./ctrl_inventory_grid.md): `['image', 'width', 'height']`

In addition to the properties listed above, you can add any bespoke properties for your project's specific needs. See [`InventoryItem`](./inventory_item.md) for usage.

## Examples

A barebones item for a [`CtrlInventory`](./ctrl_inventory.md):

```json
    {
        "id": "minimal_item"
    }
```

A 1x1 item with an image for a [`CtrlInventoryGrid`](./ctrl_inventory_grid.md):

```json
    {
        "id": "item_with_image",
        "image": "res://assets/image.png",
        "width": 1,
        "height": 1
    }
```

A heavy stackable item with an image for a [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md):

```json
    {
        "id": "heavy_stackable_item",
        "name": "Fresh-Cut Timber",
        "image": "res://assets/image.png",
        "stack_size": 10,
        "weight": 500.0
    }
```