extends CPUParticles2D

const TOTAL_SPEED: float = 500

const MIN_PARTICLES: int = 1
const MAX_PARTICLES: int = 3

func _ready() -> void:
	amount = randi_range(MIN_PARTICLES, MAX_PARTICLES)

func _on_finished() -> void:
	queue_free()

func start_particles() -> void:
	emitting = true
	print(lifetime)
	create_tween().tween_property(self, "color", Color(1,1,1,0.25), lifetime)

func set_backsplash(dir: Vector2) -> void:
	gravity.x = TOTAL_SPEED * (-dir.x)
	gravity.y = TOTAL_SPEED * (-dir.y)
