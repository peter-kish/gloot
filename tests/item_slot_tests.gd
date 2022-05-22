extends Test


func run_tests():
    var inventory1 = $Inventory1;
    var inventory2 = $Inventory2;
    var slot = $ItemSlot;
    var item = inventory1.get_items()[0];

    assert(!slot.can_hold_item(item));
    slot.inventory = inventory2;
    assert(!slot.can_hold_item(item));

    slot.inventory = inventory1;
    assert(slot.can_hold_item(item));
    slot.item = item;
    assert(slot.item == item);

    slot.inventory = inventory2;
    assert(slot.item == null);

    inventory1.transfer(item, inventory2);
    assert(slot.can_hold_item(item));
    slot.item = item;
    assert(slot.item == item);
    inventory2.remove_item(item);
    assert(slot.item == null);
