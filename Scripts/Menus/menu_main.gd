extends HBoxContainer

var controls_shown = false
var rebound_action = null

var melody = false
var fullscreen = false

onready var animation_player = get_node("Main/Main/Play/AnimationPlayer")
onready var play_button = get_node("Main/Main/Play")

#######################=READY=######################
func _ready():
	randomize()
	if not save_manager.progression['first_use']:
		animation_player.play("enter")
		play_button.connect("pressed", self, "play_anim")
		play_button.set_disabled(false)
	else:
		play_button.set_disabled(true)
	
	set_process_input(true)
	get_node("Menu Background/Background").set_modulate(Color(rand_range(0.4, 0.6), rand_range(0.4, 0.6), rand_range(0.4, 0.6), 100))
	get_node("Menu Background/Backgrounds").set_position('sphere', 2, 6)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if get_node("Settings/Timer").get_time_left() <= 0:
			get_node("Settings").toggle_controls()
			get_node("Settings/Timer").start()
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func play_anim():
	play_button.set_disabled(true)
	animation_player.play("play")
	animation_player.connect("finished", self, "play")

func play():
	get_tree().change_scene_to(preload("res://Scenes/Base/game.tscn"))
