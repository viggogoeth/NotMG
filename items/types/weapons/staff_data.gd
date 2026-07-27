class_name StaffData extends WeaponData

const PROJECTILES: int = 2
const pattern = "sine_pattern"

func attack(attacking_player: Player) -> void:
	attacking_player.attack_staff(self)

func get_stats_text() -> String:
	return "Damage: %.1f\nFire Rate: %.2f\nProjectiles: %d\nRange: %1.f" % [base_damage, base_attack_rate, PROJECTILES, range]
