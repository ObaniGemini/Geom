extends CanvasLayer

signal config_changed()

var controls_shown = false
var rebound_action = null

onready var controls = get_node("controls")
onready var game = get_node("game")
onready var octagon1 = get_node("Main/Double Octagon1")
onready var octagon2 = get_node("Main/Double Octagon2")
onready var settings_animation = get_node("AnimationPlayer")
onready var settings_button =  get_node("Main/SettingsButton")
onready var timer = get_node("Timer")

func checkHover():
	if settings_button.get_draw_mode() == 2:
		octagon1.set_scale(Vector2(0.39, 0.39))
		octagon2.set_scale(Vector2(0.39, 0.39))
		octagon1.set_modulate(Color(0.5, 0.1, 0.1))
		octagon2.set_modulate(Color(0.3, 0.1, 0.1))
	else:
		octagon1.set_scale(Vector2(0.4, 0.4))
		octagon2.set_scale(Vector2(0.4, 0.4))
		octagon1.set_modulate(Color(0.6, 0.15, 0.1))
		octagon2.set_modulate(Color(0.4, 0.1, 0.1))

func checkFullscreen():
	if save_manager.config['fullscreen'] and not OS.is_window_fullscreen():
		OS.set_window_fullscreen(true)
	elif not save_manager.config['fullscreen'] and OS.is_window_fullscreen():
		OS.set_window_fullscreen(false)

func _input(event):
	if event.type == InputEvent.KEY:
		set_process_input(false)
		if !event.is_action("ui_cancel") and rebound_action != null:
			action_assign(rebound_action, event)

func change_config(value, option):
	save_manager.config[option] = value
	save_manager.save_game()
	emit_signal("config_changed")

func toggle_action_assign(toggle, action):
	var button = action.get_node("action")
	if toggle:
		for other_action in controls.get_children():
			if save_manager.actions.has(other_action.get_name()) and other_action.get_name() != action.get_name():
				var other_button = other_action.get_node("action")
				if other_button.is_pressed():
					other_button.set_text(OS.get_scancode_string(save_manager.actions[other_action.get_name()]))
					other_button.set_pressed(false)
		
		button.set_pressed(true)
		button.set_text("...")
		
		rebound_action = action
		set_process_input(true)
	else:
		button.set_text(OS.get_scancode_string(save_manager.actions[action.get_name()]))

func action_assign(action, event, var joystick=false):
	var button = action.get_node("action")
	var action_name = action.get_name()
	
	save_manager.rebind_action(action_name, event.scancode)
	save_manager.save_game()
	
	button.set_pressed(false)
	button.set_text(OS.get_scancode_string(save_manager.actions[action_name]))

func settings_disabled(var boolean):
	for child in game.get_children():
		if child extends CheckBox:
			child.set_disabled(boolean)
	for child in controls.get_children():
		if child extends HBoxContainer:
			child.get_node("action").set_disabled(boolean)
	controls.get_node("shoot_with_mouse").set_disabled(boolean)

func toggle_controls():
	if save_manager.progression['first_use']:
		save_manager.progression['first_use'] = false
		get_node("../Main/Main/Play").set_disabled(false)
		get_node("../Main/Main/Play/AnimationPlayer").play("enter")
		get_node("../Main/Main/Play").connect("pressed", get_parent(), "play_anim")
	if controls_shown:
		settings_disabled(true)
		settings_animation.play("settings_exit")
	else:
		settings_disabled(false)
		settings_animation.play("settings_enter")
	controls_shown = !controls_shown

#######################=READY=######################
func _ready():
	for action in controls.get_children():
		var action_name = action.get_name()
		if save_manager.actions.has(action_name):
			var button = action.get_node("action")
			button.set_text(OS.get_scancode_string(save_manager.actions[action_name]))
			button.connect("toggled", self, "toggle_action_assign", [action])
		elif save_manager.config.has(action_name):
			if action extends BaseButton and action.is_toggle_mode():
				action.connect("toggled", self, "change_config", [action_name])
				action.set_pressed(save_manager.config[action_name])
	
	for action in game.get_children():
		var action_name = action.get_name()
		if save_manager.config.has(action_name):
			if action extends BaseButton and action.is_toggle_mode():
				action.connect("toggled", self, "change_config", [action_name])
				action.set_pressed(save_manager.config[action_name])
	
	checkFullscreen()
	settings_button.connect("pressed", self, "toggle_controls")
	set_process(true)

######################=PROCESS=#####################
func _process(delta):
	checkHover()
	checkFullscreen()