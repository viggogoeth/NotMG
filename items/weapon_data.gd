class_name WeaponData extends ItemData

@export var base_damage: float
@export var base_attack_rate: float
@export var range: float

func get_stats_text() -> String:
	return ""

func attack(attacking_player: Player) -> void:
	print("'attack' not implemented for base class 'WeaponData'")
