class_name FishSpawner extends Marker2D

@onready var respawn_timer = $RespawnTimer

@export var fish_scene: PackedScene
@export var fishing_minigame: FishingMinigame
@export var pond_center: Marker2D

var can_respawn = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_respawn and RandomNumberGenerator.new().randi_range(1,20) == 20:
		var new_fish = fish_scene.instantiate()
		new_fish.global_position = global_position
		new_fish.set_center(pond_center)
		new_fish.set_spawner(self)
		fishing_minigame.add_child(new_fish)
		can_respawn = false

func fish_killed() -> void:
	respawn_timer.start()


func _on_respawn_timer_timeout() -> void:
	can_respawn = true
