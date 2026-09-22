class_name OptionsMenu extends CanvasLayer

@onready var gameplay_menu = $VBoxContainer/GameplayMenu
@onready var keybindings_menu = $VBoxContainer/KeybindMenu

var calling_menu = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event.is_action_pressed("g_pause") and self.visible:
		_on_exit_button_pressed()

func _on_keybindings_tab_pressed() -> void:
	gameplay_menu.hide()
	keybindings_menu.show()

func _on_gameplay_tab_pressed() -> void:
	keybindings_menu.hide()
	gameplay_menu.show()

func show_menu(caller) -> void:
	calling_menu = caller
	caller.hide()
	show()

func _on_exit_button_pressed() -> void:
	calling_menu.show()
	hide()
