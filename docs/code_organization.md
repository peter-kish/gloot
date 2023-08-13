# Source Code Organization

The plugin source code is organized into the following directories:

* `addons/gloot/core` - Core functionality
* `addons/gloot/core/constraints` - Inventory constraints
* `addons/gloot/editor` - Inspector Plugin
* `addons/gloot/ui` - UI controls
* `examples` - Examples
* `tests` - Tests

The contents of `examples` and `tests` are not required for the plugin to function properly.

## Core functionality (`addons/gloot/core`)

Mostly contains code that implements core classes visible to the user:
* [`item_protoset.gd`](../addons/gloot/core/item_protoset.gd) - Implements [`ItemProtoset`](./item_protoset.md)
* [`inventory_item.gd`](../addons/gloot/core/inventory_item.gd) - Implements [`InventoryItem`](.inventory_item.md)
* [`inventory.gd`](../addons/gloot/core/inventory.gd) - Implements [`Inventory`](./inventory.md)
* [`inventory_stacked.gd`](../addons/gloot/core/inventory_stacked.gd) - Implements [`InventoryStacked`](./inventory_stacked.md)
* [`inventory_grid.gd`](../addons/gloot/core/inventory_grid.gd) - Implements [`InventoryGrid`](./inventory_grid.md)
* [`inventory_grid_stacked.gd`](../addons/gloot/core/inventory_grid_stacked.gd) - Implements [`InventoryGridStacked`](./inventory_grid_stacked.md)
* [`item_slot.gd`](../addons/gloot/core/item_slot.gd) - Implements [`ItemSlot`](./item_slot.md.md)

Other files in the directory:
* [`verify.gd`](../addons/gloot/core/verify.gd) - Implements some helper static functions for various error checks.

## Inventory Constraints (`addons/gloot/constraints`)

The [`InventoryStacked`](./inventory_stacked.md), [`InventoryGrid`](./inventory_grid.md) and [`InventoryGridStacked`](./inventory_grid_stacked.md) classes derive from the [`Inventory`](./inventory.md) class and apply different constraints on the basic inventory functionality. Combining these constraints gives us the functionality of the derived classes. The constraints are implemented in separate classes and can be found in the `addons/gloot/constraints` directory:
* [constraint_manager.gd](../addons/gloot/constraints/constraint_manager.gd) - Implements a constraint manager class
* [grid_constraint.gd](../addons/gloot/constraints/grid_constraint.gd) - Implements the grid constraint, which limits the inventory to a 2D grid of a given size.
* [stacks_constraint.gd](../addons/gloot/constraints/stacks_constraint.gd) - Implements the stacks constraint, which organizes the items in item stacks.
* [weight_constraint.gd](../addons/gloot/constraints/weight_constraint.gd) - Implements the weight constraint, which limits the inventory to a given weight-based capacity.

## Inspector Plugin (`addons/gloot/editor`)

Contains code that implements the inspector plugin and UI controls that will be shown in the editor (such as the inventory editors, item property editor etc.).

### `common`

Contains common controls used by the inspector plugin:
* [`choice_filter.gd`](../addons/gloot/editor/common/choice_filter.gd) and [`choice_filter.tscn`](../addons/gloot/editor/common/choice_filter.tscn) - Implements a UI control where the user can choose from a list of items and adds an option to filter the available items. Used for filtering and choosing item prototypes.
* [`choice_filter_test.tscn`](../addons/gloot/editor/common/choice_filter_test.tscn) - A scene for testing [`choice_filter.gd`](../addons/gloot/editor/common/choice_filter.gd) and [`choice_filter.tscn`](../addons/gloot/editor/common/choice_filter.tscn).
* [`dict_editor.gd`](../addons/gloot/editor/common/dict_editor.gd) and [`dict_editor.tscn`](../addons/gloot/editor/common/dict_editor.tscn) - Implements a UI control for editing dictionaries. Used for editing [`InventoryItem`](.inventory_item.md) properties.
* [`dict_editor_test.tscn`](../addons/gloot/editor/common/dict_editor_test.tscn) - A scene for testing [`dict_editor.gd`](../addons/gloot/editor/common/dict_editor.gd) and [`dict_editor.tscn`](../addons/gloot/editor/common/dict_editor.tscn).
* [`editor_icons.gd`](../addons/gloot/editor/common/editor_icons.gd) - A script for obtaining built-in editor icons.
* [`multifloat_editor.gd`](../addons/gloot/editor/common/multifloat_editor.gd) - Implements a UI control for editing multiple float values (like [`Vector2`](https://docs.godotengine.org/en/stable/classes/class_vector2.html) and [`Vector3`](https://docs.godotengine.org/en/stable/classes/class_vector3.html)). Used by [`value_editor.gd`](../addons/gloot/editor/common/value_editor.gd).
* [`value_editor.gd`](../addons/gloot/editor/common/value_editor.gd) - Implements a UI control for editing a value of arbitrary type. Used by [`dict_editor.gd`](../addons/gloot/editor/common/dict_editor.gd).

### `inventory_editor`

Contains controls for editing [`Inventory`](./inventory.md) nodes.
* [`inventory_editor.gd`](../addons/gloot/editor/inventory_editor/inventory_editor.gd) and [`inventory_editor.tscn`](../addons/gloot/editor/inventory_editor/inventory_editor.tscn) - Implements a control for editing [`Inventory`](./inventory.md) nodes.
* [`inventory_inspector.gd`](../addons/gloot/editor/inventory_editor/inventory_inspector.gd) and [`inventory_inspector.tscn`](../addons/gloot/editor/inventory_editor/inventory_inspector.tscn) - Implements a that will be added to the inspector when editing [`Inventory`](./inventory.md) nodes. Contains an [`inventory_editor.tscn`](../addons/gloot/editor/inventory_editor/inventory_editor.tscn) scene.

### `item_editor`

Contains controls for editing [`InventoryItem`](.inventory_item.md) nodes.
* [`edit_properties_button.gd`](../addons/gloot/editor/item_editor/edit_properties_button.gd) - Implements an [`EditorProperty`](https://docs.godotengine.org/en/stable/classes/class_editorproperty.html) for editing [`InventoryItem`](.inventory_item.md) properties.
* [`properties_editor.gd`](../addons/gloot/editor/item_editor/properties_editor.gd) and [`properties_editor.tscn`](../addons/gloot/editor/item_editor/properties_editor.tscn) - Implements a dialog for editing `InventoryItem` properties.
* [`edit_prototype_id_button.gd`](../addons/gloot/editor/item_editor/edit_prototype_id_button.gd) - Implements an [`EditorProperty`](https://docs.godotengine.org/en/stable/classes/class_editorproperty.html) for editing [`InventoryItem`](.inventory_item.md) prototype IDs.
* [`prototype_id_editor.gd`](../addons/gloot/editor/item_editor/prototype_id_editor.gd) and [`prototype_id_editor.tscn`](../addons/gloot/editor/item_editor/prototype_id_editor.tscn) - Implements a dialog for editing the prototype ID of an [`InventoryItem`](.inventory_item.md).

### `item_slot_editor`

Contains a control for editing [`ItemSlot`](./item_slot.md) nodes.
* [`edit_equipped_item_button.gd`](../addons/gloot/editor/item_slot_editor/edit_equipped_item_button.gd) - Implements an [`EditorProperty`](https://docs.godotengine.org/en/stable/classes/class_editorproperty.html) for editing the equipped item of an [`ItemSlot`](./item_slot.md).

### `protoset_editor`

Contains controls for editing [`ItemProtoset`](./item_protoset.md) resources.
* [`edit_protoset_button.gd`](../addons/gloot/editor/protoset_editor/edit_protoset_button.gd) and [`edit_protoset_button.tscn`](../addons/gloot/editor/protoset_editor/edit_protoset_button.tscn) - Implements a button that opens a `protoset_editor` dialog for editing protosets.
* [`protoset_editor.gd`](../addons/gloot/editor/protoset_editor/protoset_editor.gd) and [`protoset_editor.tscn`](../addons/gloot/editor/protoset_editor/protoset_editor.tscn) - Implements a dialog for editing [`ItemProtoset`](./item_protoset.md)s.

### Other Files

* [`gloot_undo_redo.gd`](../addons/gloot/editor/gloot_undo_redo.gd) - Implements editor actions as undoable and redoable operations.
* [`inventory_inspector_plugin.gd`](../addons/gloot/editor/inventory_inspector_plugin.gd) - Implements the GLoot [`EditorInspectorPlugin`](https://docs.godotengine.org/en/stable/classes/class_editorinspectorplugin.html#class-editorinspectorplugin).

## UI Controls (`addons/gloot/ui`)

Mostly contains code that implements UI controls visible to the user:
* [`ctrl_inventory.gd`](../addons/gloot/ui/ctrl_inventory.gd) - Implements [`CtrlInventory`](./ctrl_inventory.md)
* [`ctrl_inventory_stacked.gd`](../addons/gloot/ui/ctrl_inventory_stacked.gd) - Implements [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md)
* [`ctrl_inventory_grid.gd`](../addons/gloot/ui/ctrl_inventory_grid.gd) - Implements [`CtrlInventoryGrid`](./ctrl_inventory_grid.md)
* [`ctrl_inventory_grid_ex.gd`](../addons/gloot/ui/ctrl_inventory_grid_ex.gd) - Implements [`CtrlInventoryGridEx`](./ctrl_inventory_grid.md)
* [`ctrl_item_slot.gd`](../addons/gloot/ui/ctrl_item_slot.gd) - Implements [`CtrlItemSlot`](./ctrl_item_slot.md)
* [`ctrl_item_slot_ex.gd`](../addons/gloot/ui/ctrl_item_slot_ex.gd) - Implements [`CtrlItemSlotEx`](./ctrl_item_slot_ex.md)

Other files in the directory:
* [`ctrl_inventory_item_rect.gd`](../addons/gloot/ctrl_inventory_item_rect.gd) - Implements UI controls that display the inventory items inside a [`CtrlInventoryGrid`](./ctrl_inventory_grid.md).

## Examples (`examples`)

Contains example code (and scenes) that demonstrates how to use some common features of the plugin.
* [`inventory_transfer.gd`](../examples/inventory_transfer.gd) and [`inventory_transfer.tscn`](../examples/inventory_transfer.tscn) - Implements basic item transfer between two [`Inventory`](./inventory.md) nodes.
* [`inventory_stacked_transfer.gd`](../examples/inventory_stacked_transfer.gd) and [`inventory_stacked_transfer.tscn`](../examples/inventory_stacked_transfer.tscn) - Implements basic item transfer between two [`InventoryStacked`](./inventory_stacked.md) nodes.
* [`inventory_grid_transfer.gd`](../examples/inventory_grid_transfer.gd) and [`inventory_grid_transfer.tscn`](../examples/inventory_grid_transfer.tscn) - Implements basic item transfer between two [`InventoryGrid`](./inventory_grid.md) nodes.
* [`inventory_grid_ex_transfer.gd`](../examples/inventory_grid_ex_transfer.gd) and [`inventory_grid_ex_transfer.tscn`](../examples/inventory_grid_ex_transfer.tscn) - Similar to the previous, but using [`CtrlInventoryGridEx`](ctrl_inventory_grid_ex.md) and [`CtrlItemSlotEx`](ctrl_item_slot_ex.md).
* [`inventory_grid_stacked_transfer.gd`](../examples/inventory_grid_stacked_transfer.gd) and [`inventory_grid_stacked_ex_transfer.tscn`](../examples/inventory_grid_stacked_ex_transfer.tscn) - Similar to the previous, but using [`InventoryGridStacked`](inventory_grid_stacked.md).

## Tests (`tests`)

Contains unit tests and some basic scenes to test the UI control classes (such as `CtrlInventory`, `CtrlInventoryStacked` etc.). Also contains the implementation of a very simple unit test framework.
The test framework is implemented in the following two files:
* [`test_suite.gd`](../tests/test_suite.gd) - Implements a basic test suite node.
* [`test_runner.gd`](../tests/test_runner.gd) - Implements a basic test runner node.

The unit tests are implemented in the files with the `_test` suffix:
* [`item_definitions_test.gd`](../tests/item_definitions_test.gd) - Tests [`ItemProtoset`](./item_protoset.md).
* [`inventory_tests.gd`](../tests/inventory_tests.gd) - Tests [`Inventory`](./inventory.md).
* [`inventory_stacked_tests.gd`](../tests/inventory_stacked_tests.gd) - Tests [`InventoryStacked`](./inventory_stacked.md).
* [`inventory_grid_tests.gd`](../tests/inventory_grid_tests.gd) - Tests [`InventoryGrid`](./inventory_grid.md).
* [`inventory_grid_tests.gd`](../tests/inventory_grid_stacked_tests.gd) - Tests [`InventoryGridStacked`](./inventory_grid_stacked.md).
* [`item_slot_tests.gd`](../tests/item_slot_tests.gd) - Tests [`ItemSlot`](./item_slot.md).
* [`verification_test.gd`](../tests/verification_test.gd) - Tests the helper functions from [`verify.gd`](../addons/gloot/verify.gd).

The tests for inventory constraints are located in the `tests/constraint_tests` directory
* [constraint_manager_tests.gd](../tests/constraint_tests/constraint_manager_tests.gd) - Tests the constraint manager
* [grid_constraint_tests.gd](../tests/constraint_tests/grid_constraint_tests.gd) - Tests the grid constraint
* [stacks_constraint_tests.gd](../tests/constraint_tests/stacks_constraint_tests.gd) - Tests the stacks constraint
* [weight_constraint_tests.gd](../tests/constraint_tests/weight_constraint_tests.gd) - Tests the weight constraint

The UI control tests are just scenes that contain a single instance of the UI control they are supposed to test:
* [`test_ctrl_inventory.tscn`](../tests/ctrl_tests/test_ctrl_inventory.tscn) - Tests [`CtrlInventory`](./ctrl_inventory.md).
* [`test_ctrl_inventory_stacked.tscn`](../tests/ctrl_tests/test_ctrl_inventory_stacked.tscn) - Tests [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md).
* [`test_ctrl_inventory_grid.tscn`](../tests/ctrl_tests/test_ctrl_inventory_grid.tscn) - Tests [`CtrlInventoryGrid`](./ctrl_inventory_grid.md).
* [`test_ctrl_inventory_grid_ex.tscn`](../tests/ctrl_tests/test_ctrl_inventory_grid_ex.tscn) - Tests [`CtrlInventoryGridEx`](./ctrl_inventory_grid_ex.md).
* [`test_ctrl_inventory_grid_stacked.tscn`](../tests/ctrl_tests/test_ctrl_inventory_grid_stacked.tscn) - Tests [`CtrlInventoryGrid`](./ctrl_inventory_grid.md) with an [`InventoryGridStacked`](./inventory_grid_stacked.md) attached.
* [`test_ctrl_inventory_grid_stacked_ex.tscn`](../tests/ctrl_tests/test_ctrl_inventory_grid_stacked_ex.tscn) - Tests [`CtrlInventoryGridEx`](./ctrl_inventory_grid_ex.md) with an [`InventoryGridStacked`](./inventory_grid_stacked.md) attached.
* [`test_ctrl_item_slot.tscn`](../tests/ctrl_tests/test_ctrl_item_slot.tscn) - Tests [`CtrlItemSlot`](./ctrl_item_slot.md).
* [`test_ctrl_item_slot_ex.tscn`](../tests/ctrl_tests/test_ctrl_item_slot_ex.tscn) - Tests [`CtrlItemSlotEx`](./ctrl_item_slot_ex.md).
