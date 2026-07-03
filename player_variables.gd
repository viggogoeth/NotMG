extends Node

# constants 
const I_FRAMES: float = 0.4

# movement related
var movement_speed: float

# health related
var max_health: float
var current_health: float
var regen_rate: float
var is_dead: bool
var can_take_damage: bool

# attack related
var attack_cooldown : float
var can_attack : bool

# level
var current_exp : float
var current_level: int
'''
Experience needed to reach the next level is done in accordance to the (sort of) fibonacci numbers:
1 -> 2 = 100 exp
2 -> 3 = 200 exp
3 -> 4 = 300 exp
4 -> 5 = 500 exp
5 -> 6 = 800 exp
...
'''
func needed_exp_to_level() -> float:
	return _fib(current_level) * 100.0

var fibo : Array = [1,2]
func _fib(n: int) -> int:
	if fibo.size() >= n:
		return fibo[n - 1]
	var start = max(2, fibo.size())
	for i in range(start, n):
		var last = fibo[i - 1] + fibo[i - 2]
		fibo.append(last)
	return fibo.back()

func add_exp(amount: float) -> void:
	current_exp += amount
	if current_exp >= needed_exp_to_level():
		current_level += 1
		current_exp = current_exp - needed_exp_to_level()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_player_variables() -> void:
	# these are all default values for a brand new player
	movement_speed = 400.0
	
	max_health = 100.0
	current_health = 100.0
	regen_rate = 1.0
	is_dead = false
	
	can_take_damage = true
	
	attack_cooldown = 0.2
	can_attack = true
	
	current_exp = 0.0
	current_level = 1

func set_player_variables_from_save_data(save_data: Dictionary) -> void:
	#TODO: actually store all values for the player
	reset_player_variables()
	
	current_health = save_data["current_health"]
	current_exp = save_data["current_exp"]
	current_level = save_data["current_level"]
	is_dead = PlayerVariables.current_health <= 0
