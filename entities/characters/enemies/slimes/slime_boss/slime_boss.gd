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

enum State {
	hiding,
	invulnerable,
	idle,
}

enum Phase {
	one,
	two,
}

var current_state = State.hiding
var current_phase = Phase.one

func _ready() -> void:
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	phase_two.process_mode = Node.PROCESS_MODE_DISABLED
	

func _physics_process(delta: float) -> void:
	if current_state == State.invulnerable: return
	move_and_slide()

func take_damage(amount: float) -> void:
	if current_state == State.invulnerable: return
	current_health -= amount
	progress_bar.value -= amount
	if current_health <= health_threshold(current_phase):
		goto_next_phase(current_phase)

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
			create_tween().tween_property(sprites, "modulate", Color("red"), 5)
			phase_one.process_mode = Node.PROCESS_MODE_DISABLED
		_:
			print("Next phase not implemented")
			return
	velocity = Vector2.ZERO # ensure that no leftover velocity appears


func _on_invulnerability_timer_timeout() -> void:
	current_state = State.idle
	match current_phase:
		Phase.two:
			phase_two.process_mode = Node.PROCESS_MODE_INHERIT
		_:
			print("Phase not implemented in '_on_invulnerability_timer_timeout'")
			pass
