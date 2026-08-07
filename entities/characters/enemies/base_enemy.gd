class_name BaseEnemy extends CharacterBody2D

const LOOT_BAG_SCENE = preload("res://entities/loot_bag.tscn")

@export var enemy_id: String

@export var speed = 400.0
@export var health: float = 0

var dead: bool = false

@export var resistance: float = 0
@export var contact_damage: float = 0

@export var exp_amount: float = 0

@export var health_component: Node2D

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func add_exp() -> void:
	if player:
		player.add_exp(exp_amount)
	
func die() -> void:
	if dead:
		return
	dead = true
	add_exp()
	
	var drop = DropTables.get_drop(self.enemy_id)
	if drop.size() > 0:
		var lootbag: LootContainer = LOOT_BAG_SCENE.instantiate()
		lootbag.global_position = global_position
		lootbag.add_items(drop)
		get_tree().current_scene.add_child.call_deferred(lootbag)
	
	queue_free()

func take_damage(amount: float) -> void:
	var resist_adjusted_damage = amount * (1 - resistance)
	health_component.take_damage(resist_adjusted_damage)
	
