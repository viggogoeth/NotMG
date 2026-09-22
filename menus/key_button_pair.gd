class_name KeyButtonPair extends HBoxContainer

@export var action_name: String
@export var display_name: String
@export var current_bind: String

@export var containing_menu: KeyBindMenu 

@onready var label: Label = $Label
@onready var button: Button = $Button

var listening = false

func _ready():
	update_text()
	
func update_bind(bind: String) -> void:
	current_bind = bind
	update_text()

func update_text() -> void:
	label.set_text(display_name)
	button.set_text(current_bind)
	pass

func _input(event) -> void:
	if listening and (event is InputEventKey or event is InputEventMouseButton):
		get_viewport().set_input_as_handled()
		listening = false
		update_bind(event.as_text())
		Config.remap(action_name, event)

func _on_button_pressed() -> void:
	listening = true
