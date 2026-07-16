class_name InventoryMenu extends CanvasLayer

@export var player: Player
@export var inventory_resource: InventoryData
@export var equipped_weapon: SlotData

var dragged_item: ItemSlot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	hide()
	update_item_slots()

func update_item_slots() -> void:
	inventory_resource = player.inventory
	var i: int = 0
	for item in $InventoryContainer/InventoryGrid.get_children():
		var slot_data = inventory_resource.inventory_slots[i]
		item.set_data(slot_data)
		i += 1
	$EquippedContainer/EquippedGrid/Weapon.set_data(player.equipped_weapon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event) -> void:
	if event.is_action_pressed("inventory"):
		var menus = get_tree().get_nodes_in_group("menu")
		for menu in menus:
			if menu.visible == true and menu != self:
				return
		toggle_pause()
	if event.is_action_pressed("pause") and self.visible:
		pass # TODO: make escape close the inventory as well
		
	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		for item in $InventoryContainer/InventoryGrid.get_children():
			if item.hovered:
				_equip_weapon(item)
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		for item in $InventoryContainer/InventoryGrid.get_children():
			if item.hovered:
				_drop_item(item)
	

func _equip_weapon(item: ItemSlot) -> void:
	if is_instance_valid(item.slot_data.item_in_slot):
		print("Equipping weapon: %s" % item.slot_data.item_in_slot.item_name)
		var eq = player.equipped_weapon
		var inv_item = item.slot_data
		player.equipped_weapon = item.slot_data
		item.set_data(eq)
		
		
		for idx in len(inventory_resource.inventory_slots):
			if inv_item == inventory_resource.inventory_slots[idx]:
				print("Found it")
				inventory_resource.inventory_slots[idx] = eq
		
		$EquippedContainer/EquippedGrid/Weapon.set_data(player.equipped_weapon)

func _drop_item(item: ItemSlot) -> void:
	var inv_item = item.slot_data
	var new_empty_slot = SlotData.new()
	item.set_data(new_empty_slot)
	for idx in len(inventory_resource.inventory_slots):
		if inv_item == inventory_resource.inventory_slots[idx]:
			print("Found it")
			inventory_resource.inventory_slots[idx] = new_empty_slot

func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	visible = new_pause_state
	get_tree().paused = new_pause_state
