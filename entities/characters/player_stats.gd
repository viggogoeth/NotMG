class_name PlayerStats extends Resource

@export var vigor: int = 10
@export var strength: int = 10
@export var dexterity: int = 10
@export var agility: int = 10
@export var vitality: int = 10

func increase_all(amount: int) -> void:
	vigor += amount
	strength += amount
	dexterity += amount
	agility += amount
	vitality += amount
