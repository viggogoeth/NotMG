class_name SlimeBoss extends CharacterBody2D

@export var player: Player

@export var max_health: float = 1000.0
var current_health: float = max_health
@export var contact_damage: float = 25.0

@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer

@onready var sprites: Node2D = $Sprites

@onready var phase_one: Node2D = $PhaseOne
@onready var phase_two: Node2D = $PhaseTwo

@onready var animated_sprite_2d: AnimatedSprite2D = $Sprites/AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $Sound/JumpSound
@onready var land_sound: AudioStreamPlayer2D = $Sound/LandSound

enum State {
	hiding,
	invulnerable,
	idle,
	moving,
	attacking,
	attack_waiting,
}

enum Phase {
	one,
	two,
}

var current_state = State.idle
var current_phase = Phase.one

func _ready() -> void:
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	phase_two.process_mode = Node.PROCESS_MODE_DISABLED
	
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	

func _physics_process(delta: float) -> void:
	if current_state == State.invulnerable: return
	move_and_slide()

func take_damage(amount: float) -> void:
	if current_state == State.invulnerable: return
	current_health -= amount
	progress_bar.value -= amount
	if current_health <= health_threshold(current_phase):
		goto_next_phase(current_phase)
	if current_health <= 0:
		queue_free()
		player.add_exp(1000000)

func health_threshold(phase: Phase) -> float:
	match phase:
		Phase.one:
			return max_health * 0.67
		Phase.two:
			return max_health * 0.33
		_:
			return 0

func goto_next_phase(phase: Phase) -> void:
	match phase:
		Phase.one:
			current_phase = Phase.two
			print("Going to phase two")
			current_state = State.invulnerable
			invulnerability_timer.start()
			create_tween().tween_property(animated_sprite_2d, "modulate", Color("red"), 5)
			phase_one.process_mode = Node.PROCESS_MODE_DISABLED
			animated_sprite_2d.speed_scale *= 2
		_:
			print("Next phase not implemented")
			return
	animated_sprite_2d.animation = "idle"
	velocity = Vector2.ZERO # ensure that no leftover velocity appears


func _on_invulnerability_timer_timeout() -> void:
	current_state = State.idle
	match current_phase:
		Phase.two:
			phase_two.process_mode = Node.PROCESS_MODE_INHERIT
		_:
			print("Phase not implemented in '_on_invulnerability_timer_timeout'")
			pass


func _on_phase_change_state(state: SlimeBoss.State) -> void:
	var prev_state = current_state
	current_state = state
	match state:
		State.idle:
			animated_sprite_2d.animation = "idle"
			if prev_state == State.moving:
				land_sound.play()
			print("idle")
		State.moving:
			animated_sprite_2d.animation = "move"
			jump_sound.play()
			print("moving")
		State.attacking:
			print("attacking")
		State.attack_waiting:
			print("attack_waiting")
