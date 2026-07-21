class_name LootContainer extends Area2D

var player_in_range: bool = false

@export var slots_in_bag: Array[SlotData]
const BAG_SIZE: int = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractPrompt.hide()
	$Highlight.hide()
	for i in range(BAG_SIZE):
		if slots_in_bag[i]:
			slots_in_bag[i] = slots_in_bag[i].duplicate()
		else:
			slots_in_bag[i] = SlotData.new()

func _process(delta: float) -> void:
	pass

func add_items(items: Array[ItemData]) -> void:
	for i in range(items.size()):
		if not slots_in_bag[i]:
			slots_in_bag[i] = SlotData.new()
			slots_in_bag[i].item_in_slot = items[i]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range:
		get_viewport().set_input_as_handled()
		var loot_bag_menu = get_tree().get_first_node_in_group("loot_bag_menu")
		loot_bag_menu.open_loot_bag(self.slots_in_bag)

func _on_body_entered(body: Node2D) -> void:
	var loot_bags = get_tree().get_nodes_in_group("loot_bag")
	for bag: LootContainer in loot_bags:
		if bag.player_in_range == true:
			return
	player_in_range = true
	$InteractPrompt.show()
	$Highlight.show()


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
	$InteractPrompt.hide()
	$Highlight.hide()
