extends InventoryMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event) -> void:
	# only close using keyboard actions
	if (event.is_action_pressed("pause") or event.is_action_pressed("inventory") or event.is_action_pressed("interact")) and self.visible:
		toggle_pause()
		get_viewport().set_input_as_handled()
		
	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		for item in $LootBagContainer/LootBagGrid.get_children():
			if item.hovered:
				_add_item(item)

func _add_item(item: ItemSlot) -> void:
	var free_slot = _get_first_free_slot()
	if free_slot and is_instance_valid(item.slot_data.item_in_slot):
		free_slot.slot_data.item_in_slot = item.slot_data.item_in_slot
		item.slot_data.item_in_slot = null
		
		free_slot.set_data(free_slot.slot_data)
		item.set_data(item.slot_data)
		

func open_loot_bag(content: Array[SlotData]) -> void:
	toggle_pause()
	var i: int = 0
	for item in $LootBagContainer/LootBagGrid.get_children():
		if i < len(content):
			var slot_data = content[i]
			item.set_data(slot_data)
			i += 1
		else:
			item.set_data(SlotData.new())
