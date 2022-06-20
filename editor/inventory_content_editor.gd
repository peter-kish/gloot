extends EditorProperty

var editor_control: Control;
var item_list: ItemList;
var btn_add: MenuButton

# An internal value of the property.
var current_value: Array = []
# A guard against internal changes when the property is updated.
var updating = false


func _init():
    if editor_control == null:
        editor_control = _create_editor_control();
    # Add the control as a direct child of EditorProperty node.
    add_child(editor_control);
    # Make sure the control is able to retain the focus.
    add_focusable(editor_control);
    # Setup the initial state and connect to the signal to track changes.
    refresh_editor_control();


func _on_btn_add_about_to_show() -> void:
    btn_add.get_popup().clear();
    var inventory: Inventory = get_edited_object();
    if inventory:
        for prototype_id in inventory.item_protoset._prototypes.keys():
            btn_add.get_popup().add_item(prototype_id);


func _on_btn_add_index_pressed(index: int) -> void:
    # Ignore the signal if the property is currently being updated.
    if (updating):
        return;

    var prototype_id = btn_add.get_popup().get_item_text(index);
    current_value.append(prototype_id);
    refresh_editor_control();
    emit_changed(get_edited_property(), current_value);


func _on_btn_remove():
    # Ignore the signal if the property is currently being updated.
    if (updating):
        return;

    var selected_items: PoolIntArray = item_list.get_selected_items();
    for i in range(selected_items.size() - 1, -1, -1):
        current_value.remove(selected_items[i]);
    refresh_editor_control();
    emit_changed(get_edited_property(), current_value);


func update_property():
    # Read the current value from the property.
    var new_value = get_edited_object()[get_edited_property()];
    if (new_value == current_value):
        return;

    # Update the control with the new value.
    updating = true;
    current_value = new_value;
    refresh_editor_control();
    updating = false;


func refresh_editor_control():
    item_list.clear();
    for value in current_value:
        item_list.add_item(value);


func _create_editor_control() -> Control:
    var v_container: VBoxContainer = VBoxContainer.new();
    v_container.rect_min_size = Vector2(0, 256);

    item_list = ItemList.new();
    item_list.size_flags_vertical = SIZE_EXPAND_FILL;
    item_list.select_mode = 1;
    v_container.add_child(item_list);

    var h_container: HBoxContainer = HBoxContainer.new();
    v_container.add_child(h_container);

    btn_add = MenuButton.new();
    btn_add.text = "Add";
    btn_add.connect("about_to_show", self, "_on_btn_add_about_to_show");
    btn_add.get_popup().connect("index_pressed", self, "_on_btn_add_index_pressed");
    h_container.add_child(btn_add);

    var btn_remove: Button = Button.new();
    btn_remove.text = "Remove";
    btn_remove.connect("pressed", self, "_on_btn_remove");
    h_container.add_child(btn_remove);

    return v_container;