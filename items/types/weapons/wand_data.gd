class_name WandData extends WeaponData

const PROJECTILES: int = 1

func attack(attacking_player: Player) -> void:
	attacking_player.attack_wand(self)

func get_stats_text() -> String:
	return "Damage: %.1f\nFire Rate: %.2f\nProjectiles: %d\nRange: %1.f" % [base_damage, base_attack_rate, PROJECTILES, range]
