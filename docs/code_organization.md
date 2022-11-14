# Source Code Organization

The plugin source code is organized into the following directories:

* `addons/gloot/` - Core functionality
* `addons/gloot/editor` - Inspector Plugin
* `examples` - Examples
* `tests` - Tests

The contents of `examples` and `tests` are not required for the plugin to function properly.

## Core functionality (`addons/gloot/`)

Mostly contains code that implements classes visible to the user:
* [`item_protoset.gd`](../addons/gloot/item_protoset.gd) - Implements [`ItemProtoset`](./item_protoset.md)
* [`inventory_item.gd`](../addons/gloot/inventory_item.gd) - Implements [`InventoryItem`](./inventory_item.md)
* [`inventory.gd`](../addons/gloot/inventory.gd) - Implements [`Inventory`](./inventory.md)
* [`inventory_stacked.gd`](../addons/gloot/inventory_stacked.gd) - Implements [`InventoryStacked`](./inventory_stacked.md)
* [`inventory_grid.gd`](../addons/gloot/inventory_grid.gd) - Implements [`InventoryGrid`](./inventory_grid.md)
* [`ctrl_inventory.gd`](../addons/gloot/ctrl_inventory.gd) - Implements [`CtrlInventory`](./ctrl_inventory.md)
* [`ctrl_inventory_stacked.gd`](../addons/gloot/ctrl_inventory_stacked.gd) - Implements [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md)
* [`ctrl_inventory_grid.gd`](../addons/gloot/ctrl_inventory_grid.gd) - Implements [`CtrlInventoryGrid`](./ctrl_inventory_grid.md)
* [`ctrl_inventory_grid_ex.gd`](../addons/gloot/ctrl_inventory_grid_ex.gd) - Implements [`CtrlInventoryGridEx`](./ctrl_inventory_grid.md)
* [`ctrl_item_slot.gd`](../addons/gloot/ctrl_item_slot.gd) - Implements [`CtrlItemSlot`](./ctrl_item_slot.md)
* [`ctrl_item_slot_ex.gd`](../addons/gloot/ctrl_item_slot_ex.gd) - Implements [`CtrlItemSlotEx`](./ctrl_item_slot_ex.md)
* [`item_slot.gd`](../addons/gloot/item_slot.gd) - Implements [`ItemSlot`](./item_slot.md.md)
* [`gloot_autoload.gd`](../addons/gloot/gloot_autoload.gd) - Implements [`GLoot`](./gloot.md)

Other files in the directory:
* [`plugin.cfg`](../addons/gloot/plugin.cfg) - Plugin configuration file. 
* [`gloot.gd`](../addons/gloot/gloot.gd) - Main plugin script (referenced in [`plugin.cfg`](../addons/gloot/plugin.cfg)).
* [`ctrl_inventory_item_rect.gd`](../addons/gloot/ctrl_inventory_item_rect.gd) - Implements UI controls that display the inventory items inside a [`CtrlInventoryGrid`](./ctrl_inventory_grid.md).
* [`verify.gd`](../addons/gloot/verify.gd) - Implements some helper static functions for various error checks.

## Inspector Plugin (`addons/gloot/editor`)

Contains code that implements the inspector plugin and UI controls that will be shown in the editor (such as the inventory editors, item property editor etc.).
* [`choice_filter.gd`](../addons/gloot/editor/choice_filter.gd) and [`choice_filter.tscn`](../addons/gloot/editor/choice_filter.tscn) - Implements a UI control where the user can choose from a list of items and adds an option to filter the available items. Used for filtering and choosing item prototypes.
* [`choice_filter_test.tscn`](../addons/gloot/editor/choice_filter_test.tscn) - A scene for testing [`choice_filter.gd`](../addons/gloot/editor/choice_filter.gd) and [`choice_filter.tscn`](../addons/gloot/editor/choice_filter.tscn).
* [`edit_protoset_button.gd`](../addons/gloot/editor/edit_protoset_button.gd) and [`edit_protoset_button.tscn`](../addons/gloot/editor/edit_protoset_button.tscn) - Implements a button that opens the [`ItemProtoset`](./item_protoset.md) editor.
* [`dict_editor.gd`](../addons/gloot/editor/dict_editor.gd) and [`dict_editor.tscn`](../addons/gloot/editor/dict_editor.tscn) - Implements a UI control for editing dictionaries. Used for editing [`InventoryItem`](./inventory_item.md) properties.
* [`dict_editor_test.tscn`](../addons/gloot/editor/dict_editor_test.tscn) - A scene for testing [`dict_editor.gd`](../addons/gloot/editor/dict_editor.gd) and [`dict_editor.tscn`](../addons/gloot/editor/dict_editor.tscn).
* [`editor_icons.gd`](../addons/gloot/editor/editor_icons.gd) - A script for obtaining built-in editor icons.
* [`gloot_undo_redo.gd`](../addons/gloot/editor/gloot_undo_redo.gd) - Implements editor actions as undoable and redoable operations.
* [`inventory_custom_control.gd`](../addons/gloot/editor/inventory_custom_control.gd) and [`inventory_custom_control.tscn`](../addons/gloot/editor/inventory_custom_control.tscn) - Implements a custom control for editing [`Inventory`](./inventory.md) nodes.
* [`item_property_editor.gd`](../addons/gloot/editor/item_property_editor.gd) - Implements an [`EditorProperty`](https://docs.godotengine.org/en/stable/classes/class_editorproperty.html) for editing [`InventoryItem`](./inventory_item.md) properties.
* [`item_prototype_editor.gd`](../addons/gloot/editor/item_prototype_editor.gd) - Implements an [`EditorProperty`](https://docs.godotengine.org/en/stable/classes/class_editorproperty.html) for editing [`InventoryItem`](./inventory_item.md) prototype IDs.
* [`item_slot_equipped_item_editor.gd`](../addons/gloot/editor/item_slot_equipped_item_editor.gd) - Implements an [`EditorProperty`](https://docs.godotengine.org/en/stable/classes/class_editorproperty.html) for editing the equipped item of an [`ItemSlot`](./item_slot.md).
* [`inventory_inspector_plugin.gd`](../addons/gloot/editor/inventory_inspector_plugin.gd) - Implements the GLoot [`EditorInspectorPlugin`](https://docs.godotengine.org/en/stable/classes/class_editorinspectorplugin.html#class-editorinspectorplugin).
* [`multifloat_editor.gd`](../addons/gloot/editor/multifloat_editor.gd) - Implements a UI control for editing multiple float values (like [`Vector2`](https://docs.godotengine.org/en/stable/classes/class_vector2.html) and [`Vector3`](https://docs.godotengine.org/en/stable/classes/class_vector3.html)). Used by [`value_editor.gd`](../addons/gloot/editor/value_editor.gd).
* [`protoset_editor.gd`](../addons/gloot/editor/protoset_editor.gd) and [`protoset_editor.tscn`](../addons/gloot/editor/protoset_editor.tscn) - Implements a UI control for editing [`ItemProtoset`](./item_protoset.md)s.
* [`value_editor.gd`](../addons/gloot/editor/value_editor.gd) - Implements a UI control for editing a value of arbitrary type. Used by [`dict_editor.gd`](../addons/gloot/editor/dict_editor.gd).

## Examples (`examples`)

Contains example code (and scenes) that demonstrates how to use some common features of the plugin.
* [`inventory_transfer.gd`](../examples/inventory_transfer.gd) and [`inventory_transfer.tscn`](../examples/inventory_transfer.tscn) - Implements basic item transfer between two [`Inventory`](./inventory.md) nodes.
* [`inventory_stacked_transfer.gd`](../examples/inventory_stacked_transfer.gd) and [`inventory_stacked_transfer.tscn`](../examples/inventory_stacked_transfer.tscn) - Implements basic item transfer between two [`InventoryStacked`](./inventory_stacked.md) nodes.
* [`inventory_grid_transfer.gd`](../examples/inventory_grid_transfer.gd) and [`inventory_grid_transfer.tscn`](../examples/inventory_grid_transfer.tscn) - Implements basic item transfer between two [`InventoryGrid`](./inventory_grid.md) nodes.
* [`inventory_grid_ex_transfer.gd`](../examples/inventory_grid_ex_transfer.gd) and [`inventory_grid_ex_transfer.tscn`](../examples/inventory_grid_ex_transfer.tscn) - Similar to the previous, but using [`CtrlInventoryGridEx`](ctrl_inventory_grid_ex.md) and [`CtrlItemSlotEx`](ctrl_item_slot_ex.md).

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
* [`item_slot_tests.gd`](../tests/item_slot_tests.gd) - Tests [`ItemSlot`](./item_slot.md).
* [`verification_test.gd`](../tests/verification_test.gd) - Tests the helper functions from [`verify.gd`](../addons/gloot/verify.gd).

The UI control tests are just scenes that contain a single instance of the UI control they are supposed to test:
* [`test_ctrl_inventory.tscn`](../tests/ctrl_tests/test_ctrl_inventory.tscn) - Tests [`CtrlInventory`](./ctrl_inventory.md).
* [`test_ctrl_inventory_stacked.tscn`](../tests/ctrl_tests/test_ctrl_inventory_stacked.tscn) - Tests [`CtrlInventoryStacked`](./ctrl_inventory_stacked.md).
* [`test_ctrl_inventory_grid.tscn`](../tests/ctrl_tests/test_ctrl_inventory_grid.tscn) - Tests [`CtrlInventoryGrid`](./ctrl_inventory_grid.md).
* [`test_ctrl_inventory_grid_ex.tscn`](../tests/ctrl_tests/test_ctrl_inventory_grid_ex.tscn) - Tests [`CtrlInventoryGridEx`](./ctrl_inventory_grid_ex.md).
* [`test_ctrl_item_slot.tscn`](../tests/ctrl_tests/test_ctrl_item_slot.tscn) - Tests [`CtrlItemSlot`](./ctrl_item_slot.md).
* [`test_ctrl_item_slot_ex.tscn`](../tests/ctrl_tests/test_ctrl_item_slot_ex.tscn) - Tests [`CtrlItemSlotEx`](./ctrl_item_slot_ex.md).
