extends CanvasLayer

var fullscreen = false
var menu_shown = false

onready var background = get_node("/root/game/Background/Backgrounds")

onready var settings = get_node("Settings")
onready var settings_animation = get_node("Settings/AnimationPlayer")

onready var exit_button = get_node("Main/Main/Exit")
onready var exit_animation = get_node("Main/Main/Exit/AnimationPlayer")

onready var animation_player = get_node("AnimationPlayer")
onready var timer = get_node("Timer")

#######################=READY=######################
func _ready():
	exit_button.connect("pressed", self, "exit_anim")
	get_node("Settings/Main").set_pos(Vector2(310, 660))
	settings.set_process(false)
	
	set_process_input(true)

func _input(event):
	if event.is_action("show_menu"):
		if timer.get_time_left() <= 0:
			if menu_shown:
				if settings.controls_shown:
					settings.settings_disabled(true)
					settings_animation.play("settings_exit")
				animation_player.play("exit_menu")
				settings.set_process(false)
				settings.settings_button.set_disabled(true)
			else:
				if settings.controls_shown:
					settings.settings_disabled(false)
					settings_animation.play("settings_enter")
				animation_player.play("open_menu")
				settings.set_process(true)
				settings.settings_button.set_disabled(false)
			timer.start()
			menu_shown = !menu_shown

func exit_anim():
	exit_button.set_disabled(true)
	exit_animation.play("exit")
	exit_animation.connect("finished", get_parent(), "exit")