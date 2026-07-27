class_name SwordData extends WeaponData

func attack(attacking_player: Player) -> void:
	attacking_player.attack_sword(self)

func get_stats_text() -> String:
	return "Damage: %.1f\nFire Rate: %.2f\nRange: %1.f" % [base_damage, base_attack_rate, range]
