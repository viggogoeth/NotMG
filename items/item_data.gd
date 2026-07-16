class_name ItemData extends Resource

@export var item_id: String
@export var item_name: String
@export var item_stats: ItemStats
@export var rarity: int
@export var texture: Texture2D

func get_stats_text() -> String:
	return ""
