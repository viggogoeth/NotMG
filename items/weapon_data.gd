class_name WeaponData extends ItemData

@export var base_damage: float
@export var base_attack_rate: float
@export var projectiles_count: int
@export var range: float
@export var pattern: String

func get_stats_text() -> String:
	return "Damage: %.1f\nFire Rate: %.2f\nProjectiles: %d\nRange: %1.f" % [base_damage, base_attack_rate, projectiles_count, range]
