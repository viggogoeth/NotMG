extends HBoxContainer

@export var action_name: String
@export var current_bind: String

@onready var label = $Label
@onready var button = $Button

func update_bind(bind: String) -> void:
	current_bind = bind
	update_text()

func update_text() -> void:
	label.text = action_name
	button.text = current_bind

func update_bind() -> void:
	
