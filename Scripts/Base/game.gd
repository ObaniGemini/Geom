extends Node2D

signal back_to_lobby()

var rythm_start = false
var random_music

var game_over = false

var shapes = [false, false, false, false, false, false, false]
var shapes_name = ['circle', 'sphere', 'square', 'firework', 'triangle', 'difform', 'capsule_cristal']
var shapes_random = [2, 2, 2, 2, 2, 3, 4]
var shapes_sounds = [6, 6, 8, 5, 6, 6, 4]

var lobby = true
var starting = true

var speed = false
var rythm = false

onready var player = get_node('player')
onready var backgrounds = get_node('Background/Backgrounds')
onready var hud = get_node('hud/hud')

func load_level(pack, level=null):
	if level != 0:
		if not get_node('Rythmics/Rythmic1').is_connected('finished', self, 'rythmic_play') and pack != 'lobby':
			if save_manager.config['rythm'] and not rythm:
				rythm = true
				random_music = '1'
				get_node('Rythmics/Rythmic1').play()
			get_node('Rythmics/Rythmic1').connect('finished', self, 'rythmic_play')
			get_node('Rythmics/Rythmic2').connect('finished', self, 'rythmic_play')
			get_node('Rythmics/Rythmic3').connect('finished', self, 'rythmic_play')
	
	var holder = get_node('level_holder')
	var player = get_node('player')
	player.tilemap = null
	
	for i in range(holder.get_child_count()):
		holder.get_child(i).queue_free()
	
	var level_load = load(str('res://Scenes/Levels/',pack,'/', 'level_', pack, '_', str(level), '.tscn'))
	
	if level_load != null:
		save_manager.pack = pack
		if level == null:
			save_manager.level = 0
		else:
			save_manager.level = level
		resource_manager.fix_amounts()
		save_manager.save_game()
		holder.add_child(level_load.instance())
		player.tilemap = level_load.instance()
		player.setCheckpoint(level_load.instance().get_node('spawn'))
		if player.speed:
			player.color_mode = Color(0.4, 0.5, 0.7)
		else:
			player.color_mode = Color(0.2, 0.7, 0.3)
		player.restart_from_checkpoint()
		get_node('Background/Background').set_modulate(Color(rand_range(0.4, 0.6), rand_range(0.4, 0.6), rand_range(0.4, 0.6), 1))
		checkLobby()
	else:
		player.queue_free()
		queue_free()
		print('level_', str(pack), '_', str(level), '.tscn couldn\'t be loaded. Make sure it exists, or all the scenes that it has as a child exist')
		exit()

func checkLobby():
	checkShapes()
	if not starting:
		if save_manager.pack == 'lobby' and not lobby:
			if resource_manager.is_connected('amount_changed', self, 'resource_amount_changed'):
				resource_manager.disconnect('amount_changed', self, 'resource_amount_changed')
			lobby = true
			hud.hide_game_hud()
		else:
			checkLevels()
	else:
		starting = false
	
	if lobby:
		backgrounds.set_position('sphere', 2, 6)

func checkShapes():
	for i in range(shapes.size()):
		var j = i - 1
		if i > save_manager.level and shapes[j]:
			shapes[j] = false
			backgrounds.stop(shapes_name[j])

func checkLevels():
	checkShapes()
	if save_manager.pack != 'lobby' and lobby:
		hud.show_game_hud()
		rythm_start = true
		lobby = false
		starting = false
	
	if save_manager.level <= shapes.size() and not shapes[save_manager.level - 1]:
		if save_manager.level == 1:
			resource_manager.connect('amount_changed', self, 'resource_amount_changed')
			resource_manager.set_resource_amount('stars', 2)
			backgrounds.stop_all()
		var j = save_manager.level - 1
		shapes[j] = true
		backgrounds.set_position(shapes_name[j], shapes_random[j], shapes_sounds[j])

func restart_level():
	load_level(str(save_manager.pack), save_manager.level)

func next_level():
	load_level(str(save_manager.pack), save_manager.level + 1)

func back_level():
	load_level(str(save_manager.pack), save_manager.level - 1)


func back_to_lobby():
	emit_signal('back_to_lobby')
	load_level('lobby')

func resource_amount_changed(name):
	if not lobby:
		if name == 'stars':
			var stars = resource_manager.get_resource_amount(name)

func change_config(value, option):
	save_manager.config[option] = value

func checkPlayerSpeed():
	if get_node('player').speed and not speed:
		backgrounds.set_position('rectangle', 2, 5)
		speed = true
	elif not get_node('player').speed and speed:
		speed = false
		backgrounds.stop('rectangle')

func checkRythm():
	if rythm_start:
		if save_manager.config['rythm'] and not rythm:
			rythm = true
			rythmic_play()
		elif not save_manager.config['rythm'] and rythm:
			rythm = false
			get_node(str('Rythmics/Rythmic', random_music)).stop()

#######################=READY=######################
func _ready():
	back_to_lobby()
	set_process(true)

######################=PROCESS=#####################
func _process(delta):
	checkPlayerSpeed()
	checkRythm()

func rythmic_play():
	random_music = str(randi()% 3 + 1)
	get_node(str('Rythmics/Rythmic', random_music)).play()

func exit():
	get_tree().change_scene_to(preload('res://Scenes/Menus/menu_main.tscn'))