class_name ItemSlot extends TextureRect

@export var slot_data: SlotData

var hovered: bool = false
var dragged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Tooltip.hide()
	$Tooltip/VBoxContainer/ItemName.text = ""
	$Tooltip/VBoxContainer/Stats.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Tooltip.visible:
		$Tooltip.global_position = get_global_mouse_position() + Vector2(5, 5)
	if dragged:
		global_position = get_global_mouse_position()

func set_data(data: SlotData) -> void:
	if is_instance_valid(data):
		slot_data = data
		if is_instance_valid(slot_data.item_in_slot):
			var item = slot_data.item_in_slot
			$Tooltip/VBoxContainer/ItemName.text = item.item_name
			# TODO: instance_of is not that nice? what happens when there are 30 different item archetypes
			if item is WeaponData:
				_set_stats_on_weapon(item)
			# TODO: set the texture here based on ID (using a map?)
			_set_texture(item)
			_set_rarity_color(item.rarity)
		else:
			texture = null

func _set_stats_on_weapon(item: WeaponData) -> void:
	$Tooltip/VBoxContainer/Stats.text = "Damage: %.1f\nFire Rate: %.2f\nProjectiles: %d\nRange: %1.f" % [item.base_damage, item.base_attack_rate, item.projectiles_count, item.range]

func _set_texture(item: ItemData) -> void:
	texture = item.texture
	
func _set_rarity_color(rarity: int) -> void:
	match rarity:
		0, 1:
			$Tooltip/VBoxContainer/ItemName.label_settings.font_color = Color("white")
		2:
			$Tooltip/VBoxContainer/ItemName.label_settings.font_color = Color("blue")
		3:
			$Tooltip/VBoxContainer/ItemName.label_settings.font_color = Color("yellow")
		4:
			$Tooltip/VBoxContainer/ItemName.label_settings.font_color = Color("orange")
		5:
			$Tooltip/VBoxContainer/ItemName.label_settings.font_color = Color("pink")
			
# displays the tooltip about the item
func _on_mouse_entered() -> void:
	hovered = true
	if is_instance_valid(slot_data.item_in_slot):
		$Tooltip.show()


# hides tooltip about the item
func _on_mouse_exited() -> void:
	hovered = false
	$Tooltip.hide()
