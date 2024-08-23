import argparse
from xml_to_md import xml_to_md
import os

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot_bin", default="godot", help="Godot binary")
    args = parser.parse_args()

    files = {
        "docs/CtrlInventory.xml": "docs/ctrl_inventory.md",
        "docs/CtrlInventoryCapacity.xml": "docs/ctrl_inventory_capacity.md",
        "docs/CtrlInventoryGrid.xml": "docs/ctrl_inventory_grid.md",
        "docs/CtrlInventoryItem.xml": "docs/ctrl_inventory_item.md",
        "docs/CtrlInventoryItemBase.xml": "docs/ctrl_inventory_item_base.md",
        "docs/CtrlItemSlot.xml": "docs/ctrl_item_slot.md",

        "docs/Inventory.xml": "docs/inventory.md",
        "docs/InventoryConstraint.xml": "docs/inventory_constraint.md",
        "docs/InventoryItem.xml": "docs/inventory_item.md",
        "docs/ItemCountConstraint.xml": "docs/item_count_constraint.md",
        "docs/ItemSlot.xml": "docs/item_slot.md",
        "docs/ProtoTree.xml": "docs/prototree.md",
        "docs/Prototype.xml": "docs/prototype.md",
        "docs/GridConstraint.xml": "docs/grid_constraint.md",
        "docs/WeightConstraint.xml": "docs/weight_constraint.md",
    }

    if os.system(f"{args.godot_bin} --editor --path . --doctool docs/ --gdscript-docs .") != 0:
        return 1
    
    for xml_file in files:
        xml_to_md(xml_file, files[xml_file])

    if os.system("rm docs/*.xml") != 0:
        return 1

if __name__ == "__main__":
    main()
