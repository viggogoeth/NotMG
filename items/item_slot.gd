class_name ItemSlot extends PanelContainer

@export var slot_data: SlotData

var hovered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Tooltip.hide()
	$Tooltip/VBoxContainer/ItemName.text = ""
	$Tooltip/VBoxContainer/Stats.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Tooltip.visible:
		$Tooltip.global_position = get_global_mouse_position() + Vector2(5, 5)

func set_data(data: SlotData) -> void:
	if is_instance_valid(data):
		slot_data = data
		if is_instance_valid(slot_data.item_in_slot):
			var item = slot_data.item_in_slot
			$Tooltip/VBoxContainer/ItemName.text = item.item_name
			$Tooltip/VBoxContainer/Stats.text = item.get_stats_text()

			_set_texture(item)
			_set_rarity_color(item.rarity)
		else:
			$ItemIcon.texture = null

func _set_texture(item: ItemData) -> void:
	$ItemIcon.texture = item.texture
	
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

func _get_drag_data(at_position: Vector2) -> Variant:
	if not is_instance_valid(slot_data.item_in_slot):
		return null
		
	var drag_data = {
		"origin_slot": self,
		"item_data": slot_data.item_in_slot
	}
	
	# add texture dragging
	var preview = TextureRect.new()
	preview.texture = $ItemIcon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(64, 64)
	preview.position = -preview.custom_minimum_size / 2
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var preview_container = Control.new()
	preview_container.add_child(preview)
	preview_container.z_index = 10
	set_drag_preview(preview_container)
	
	return drag_data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("origin_slot")
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var origin_slot = data["origin_slot"]
	
	if origin_slot == self:
		return
		
	var temp_item = self.slot_data.item_in_slot
	
	self.slot_data.item_in_slot = origin_slot.slot_data.item_in_slot
	
	origin_slot.slot_data.item_in_slot = temp_item
	self.set_data(self.slot_data)
	origin_slot.set_data(origin_slot.slot_data)

func show_menu() -> void:
	$RightClickMenu.show()
