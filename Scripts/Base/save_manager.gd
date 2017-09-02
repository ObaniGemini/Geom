extends Node

const action_list = [
	'move_up', 'move_left', 'move_right', 'move_down',
	'shoot_up', 'shoot_left', 'shoot_right', 'shoot_down', 'state_switch'
]

const default_config = {
	shoot_with_mouse = true,
	fullscreen = false,
	rythm = true,
	melody = true,
	sounds = true
}

const starting_state = {
	first_use = true,
	quarsh_power = false,
	bullet_type = "yellow"
}

var config = {}
var actions = {}
var progression = {}
var default_actions = {}

var pack
var level

onready var resource_manager = get_node("/root/resource_manager")

func _ready():
	for action in action_list:
		if !action.begins_with("ui_"):
			for trigger in InputMap.get_action_list(action):
				default_actions[action] = -1
				if trigger.type == InputEvent.KEY:
					default_actions[action] = trigger.scancode
					break
	
	load_game()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()

func load_game():
	level = 1
	var stars = 0
	actions = default_actions
	config = default_config
	progression = starting_state
	
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://savedata.bin", File.READ, "Geom")
	
	if !err:
		level = f.get_64()
		stars = f.get_64()
		actions = f.get_var()
		config = f.get_var()
		progression = f.get_var()
	
	if actions == null:
		actions = default_actions
	else:
		for action in default_actions:
			if !actions.has(action) or actions[action] == -1:
				actions[action] = default_actions[action]
	for action in actions:
		rebind_action(action, actions[action])
	
	if config == null:
		config = default_config
	else:
		for option in default_config:
			if !config.has(option):
				config[option] = default_config[option]
	
	if progression == null:
		progression = starting_state
	else:
		for option in starting_state:
			if !progression.has(option):
				progression[option] = starting_state[option]
	
	f.close()
	resource_manager.set_resource_amount("stars", stars)
	print(actions)
	print(config)
	print(progression)

func save_game():
	var stars = resource_manager.get_resource_amount("stars")
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://savedata.bin", File.WRITE, "Geom")
	f.store_64(level)
	f.store_64(min(stars, 0))
	f.store_var(actions)
	f.store_var(config)
	f.store_var(progression)
	f.close()

func rebind_action(action_name, scancode):
	actions[action_name] = scancode
	
	var event = InputEvent()
	event.type = InputEvent.KEY
	event.scancode = scancode
	
	for old_event in InputMap.get_action_list(action_name):
		if old_event.type == InputEvent.KEY: 
			InputMap.action_erase_event(action_name, old_event)
	
#	if InputMap.get_action_list(action_name).size() > 0:
#		InputMap.erase_action(action_name)
#		InputMap.add_action(action_name)
	
	InputMap.action_add_event(action_name, event)