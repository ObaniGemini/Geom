extends RigidBody2D

signal health_changed(amount)
signal state_changed

export(PackedScene) var bullet_scene

const bullet_class = preload("res://Scripts/Entities/entity_bullet.gd")

const start_health = 10.0
const quarsh_damage = 1.0

const normal_color = Color(0.2, 0.7, 0.3)
const speed_color = Color(0.4, 0.5, 0.7)
const death_color = Color(0.4, 0.15, 0.1)
const save_color = Color(0.7, 0.5, 0.2)

const normal_canvas = Color(1, 1, 1)
const speed_canvas = Color(0.8, 1, 1.1)
const save_canvas = Color(1.1, 1, 0.8)

var debug = false

var auto_heal_time = 2.0
var health = 10.0
var auto_heal = -1
var move_speed = 50.0

var mode = 0
var move

var camera_zoom = Vector2(4, 4)
var mouse_pos = Vector2(0,1)
var last_shot = -1000
var shoot_angle = 0
var time = 0.0
var respawn_timer = 0.5

var dead = false
var save = false
var can_move = false
var can_switch = false
var speed = false
var timer = false
var small

var after_animation = ""
var tilemap
var last_checkpoint

var canvas_mode
var color_mode
var color_end

onready var camera = get_node("Camera")
onready var sprite = get_node("Sprite")
onready var trail = get_node("Trail")
onready var particles = get_node("Particles")

onready var animation_player = get_node("AnimationPlayer")
onready var tween = get_node("Tween")
onready var tween_timer = get_node("../DeathTimer/Tween")
onready var timer_progressbar = get_node("../DeathTimer/ProgressBar")

onready var canvasmodulate = get_node("CanvasModulate")

onready var shape1 = get_node("shape").get_shape().duplicate()
onready var shape2 = get_node("shape").get_shape().duplicate()
onready var shape3 = preload("res://Scenes/Base/player/quarsh_shape.tres")
onready var shape4 = shape3.duplicate()

onready var game = get_parent()
onready var sprites = [get_node("Sprite"), get_node("Quarsh/Sprite1"), get_node("Quarsh/Sprite2")]
onready var trails = [get_node("Trail"), get_node("Trail Quarsh")]

var movement_actions = {
	move_up = Vector2(0, -1),
	move_down = Vector2(0, 1),
	move_left = Vector2(-1, 0),
	move_right = Vector2(1, 0)
}

var shooting_actions = {
	shoot_up = Vector2(0, -1),
	shoot_down = Vector2(0, 1),
	shoot_left = Vector2(-1, 0),
	shoot_right = Vector2(1, 0)
}

var special_tiles = {
	death = "restart", death45_empty = "restart", death45_wall = "restart",
	win = "next_level", win45_empty = "next_level", win45_wall = "next_level",
	peaceful = "save",
	speed = "speed",
	nospeed = "nospeed",
	finish = "finish"
}

func setHealth(amount):
	if not game.lobby:
		var loss = abs(amount - health)
		health = amount
		if amount == null:
			health = 0
		if health <= 0 and not dead:
			die()
		elif health > start_health:
			health = start_health
		
		emit_signal("health_changed", loss)

func setCheckpoint(checkpoint):
	last_checkpoint = checkpoint


func setTrail(var boolean=null, var path=null):
	if boolean == true and path == null:
		trail.set_emitting(true)
	else:
		trail.set_emitting(false)
	
	if path != null:
		trail = get_node(path)
		trail.set_emitting(true)
	
	if mode == 0:
		if small:
			trail.set_param(11, 0.5)
			trail.set_param(12, 0.3)
		else:
			trail.set_param(11, 1)
			trail.set_param(12, 0.6)
	
	trail.set_color(color_mode)

func setColor(color, ending=false, canvas=normal_canvas, opacity=1):
	color_mode = color
	for object in sprites:
		object.set_modulate(color)
	for object in trails:
		object.set_color(Color(color.r, color.g, color.b, opacity))
	if ending:
		color_end = color
	
	canvas_mode = canvas
	canvasmodulate.set_color(canvas)


func setPlayerState():
	if small:
		stateSmall()
	else:
		stateNosmall()
	
	if save and can_move:
		if speed:
			stateSpeed(false)
		stateSave()
	elif speed:
		stateSpeed()
	elif dead:
		sprite.set_modulate(death_color)
	else:
		stateNospeed()


func setMode(set):
	mode = set
	if mode == 0:
		quarsh_no_state()
		hide(get_node("Quarsh"))
		show(sprite)
	elif mode == 1:
		quarsh_state()
		hide(sprite)
		show(get_node("Quarsh"))

func ModeSwitch():
	if can_switch:
		if mode == 0 and save_manager.progression['quarsh_power']:
			setMode(1)
		elif mode == 1:
			setMode(0)


func show(var node):
	node.show()
#	switch_tween.interpolate_property(node, "transform/scale", Vector2(0,0), Vector2(1,1), 0.3, 1, 1)
#	switch_tween.start()

func hide(var node):
	node.hide()
#	switch_tween.interpolate_property(node, "transform/scale", node.get_scale(), Vector2(0,0), 0.3, 1, 1)
#	switch_tween.start()


func PlaySound(sound):
	if save_manager.config['sounds']:
		get_node("SamplePlayer").play(sound)


func shoot(direction):
	if not save:
		if time > 0.15:
			if save_manager.progression.bullet_type == "yellow":
				var random_direction = Vector2(rand_range(-0.1, 0.1), rand_range(-0.1, 0.1))
				var new_bullet = bullet_scene.instance()
				var velocity = (direction + random_direction)*(new_bullet.speed*1.5)
				new_bullet.set_pos(get_pos() + direction*60)
				new_bullet.set_linear_velocity(velocity + (get_linear_velocity()*2)/3)
				new_bullet.set_bullet_type(save_manager.progression.bullet_type)
			
				game.add_child(new_bullet)
			elif save_manager.progression.bullet_type == "light_blue":
				shoot_angle += PI/20
				if shoot_angle >= PI/2:
					shoot_angle = 0
				for i in range(8):
					var new_bullet = bullet_scene.instance()
					var angle = Vector2(cos((PI/4)*i+shoot_angle), sin((PI/4)*i+shoot_angle))
					var velocity = angle*(new_bullet.speed*1.5)
					new_bullet.set_pos(get_pos() + angle*100)
					new_bullet.set_linear_velocity(velocity + (get_linear_velocity()*3)/4)
					new_bullet.set_bullet_type(save_manager.progression.bullet_type)
					game.add_child(new_bullet)
			PlaySound("bullet")
			time = 0.0


func restart_from_checkpoint():
	respawn_timer = 0.5
	dead = false
	can_move = true
	can_switch = true
	set_linear_velocity(Vector2(0,0))
	if save_manager.pack == "lobby":
		if color_mode == death_color:
			speed = false
			if small:
				normal_state()
			emit_signal("state_changed")
	
	setTrail(true)
	set_pos(last_checkpoint.get_pos())
	setHealth(start_health)
	
	tween.set_active(true)
	timer_progressbar.set_value(0)
	
	PlaySound("spawn")
	after_animation = "enter"
	animation_player.play("enter")
	camera.set_rot(0)
	smoothing_enter()
	yield(tween, "tween_complete")
	set_z(0)


func add_health(amount, var factor=1):
	if not dead:
		setHealth(health + amount)
		if amount < 0 and not dead:
			for object in trails:
				tween.interpolate_property(object, "color/color", \
							Color((color_mode.r + (amount*0.15)), \
							(color_mode.g + (amount*0.15)), \
							(color_mode.b + (amount*0.15))), \
							color_mode, 0.4, 1, 1)
				tween.start()
			for object in sprites:
				tween.interpolate_property(object, "modulate", \
							Color((color_mode.r + (amount*0.15)), \
							(color_mode.g + (amount*0.15)), \
							(color_mode.b + (amount*0.15))), \
							color_mode, 0.4, 1, 1)
				tween.start()
			
			tween.interpolate_property(canvasmodulate, "color", \
									Color((canvas_mode.r - (amount*0.05)), \
									(canvas_mode.g + (amount*0.05)), \
									(canvas_mode.b + (amount*0.05))), \
									canvas_mode, 0.4, 1, 1)
			tween.start()
			
			tween.interpolate_property(camera, "transform/rot", (2*amount*factor), 0, rand_range(0.3, 0.5)*factor, (randi()%7 + 1), 1)
			tween.start()


func tween_complete(object, key):
	if object == sprite:
		emit_signal("state_changed")
	elif object == timer_progressbar:
		die()


func exit(var param):
	tween.stop_all()
	tween.set_active(false)
	can_move = false
	can_switch = false
	save = true
	animation_player.play("exit")
	setMode(0)
	setTrail(false)
	set_z(2)
	
	if param == "restart" or param == "rollback":
		color_mode = Color(0.4, 0.15, 0.1)
		PlaySound("death")
		after_animation = param
	else:
		color_mode == color_end
		PlaySound("next_level")
		if not dead:
			setHealth(start_health)
		
		color_mode = color_end
		after_animation = param


func die(object=null, key=null):
	dead = true
	
	setHealth(0.0)
	animation_player.stop_all()
	tween.set_active(false)
	tween.stop_all()
	
	if not game.lobby:
		if resource_manager.get_resource_amount("stars") - 1 >= 0:
			resource_manager.add_resource_amount("stars", -1, true)
			exit("restart")
		else:
			exit("rollback")
	else:
		exit("restart")


func animation_player_finish():
	var animation_name = animation_player.get_current_animation()
	if animation_name == "exit":
		if after_animation == "restart":
			restart_from_checkpoint()
		elif after_animation == "next_level":
			game.next_level()
		elif after_animation == "rollback":
			if save_manager.level > 1:
				resource_manager.set_resource_amount("stars", 2)
				game.back_level()
			else:
				game.back_to_lobby()
		elif after_animation == "finish":
			game.back_to_lobby()
		else:
			print(after_animation)


func smoothing_enter():
	tween.interpolate_property(sprite, "modulate", color_mode, color_end, 0.3, 0, 1)
	tween.start()


func checkHeal():
	if(auto_heal <= 0):
		auto_heal = auto_heal_time
		add_health(1)


func checkActionsState():
	if not get_node("../Game Menu").menu_shown:
		can_switch = true
		for action in movement_actions:
			if Input.is_action_pressed(action):
				move += movement_actions[action]
		
		for action in shooting_actions:
			var shoot_direction = Vector2(0, 0)
			if Input.is_action_pressed(action):
				shoot_direction += shooting_actions[action]
			if Input.is_action_pressed("shoot_mouse") and save_manager.config.has('shoot_with_mouse') and save_manager.config['shoot_with_mouse']:
				shoot(mouse_pos.normalized())
			elif shoot_direction.length_squared() > 0.1:
				shoot(shoot_direction.normalized())
	else:
		can_switch = false


func checkSave():
	if save:
		save = false
		emit_signal("state_changed")


#######################=READY=######################
func _ready():
	shape2.set_radius(30)
	shape4.set_extents(Vector2(16, 16))
	animation_player.connect("finished", self, "animation_player_finish")
	connect("state_changed", self, "setPlayerState")
	tween.connect("tween_complete", self, "tween_complete")
	
	color_mode = normal_color
	color_end = normal_color
	
	setHealth(start_health)
	normal_state()
	emit_signal("state_changed")
	
	set_fixed_process(true)
	set_process_input(true)


###################=FIXED PROCESS=##################
func _fixed_process(delta):
	time += delta
	auto_heal -= delta
### Used for tilemap death zones
	if respawn_timer >= 0:
		respawn_timer -= delta
	
	move = Vector2(0, 0)
	
	checkHeal()
#	checkPlayerState()
	
#	camera.set_zoom(camera_zoom + get_linear_velocity()/200) ### Psychedelic mode
	
	if can_move:
		if mode !=1:
			checkActionsState()
			var force = move.normalized()*move_speed
			apply_impulse(Vector2(0,0), force)
		if tilemap != null:
			var tile_pos = tilemap.world_to_map(get_pos())
			var tile = tilemap.get_cell(tile_pos.x, tile_pos.y)
			
			if tile >= 0:
				if timer:
					timer = false
					tween_timer.stop(timer_progressbar, "range/value")
					tween_timer.interpolate_property(timer_progressbar, "visibility/self_opacity", 0.5, 0, 0.2, 1, 1)
					tween_timer.start()
					tween_timer.disconnect("tween_complete", self, "die")
				var tile_name = tilemap.get_tileset().tile_get_name(tile)
				if special_tiles.has(tile_name):
					var tile_prop = special_tiles[tile_name]
					if tile_prop == "restart" and not dead and mode != 1:
						checkSave()
						die()
					elif tile_prop == "next_level":
						exit("next_level")
					elif tile_prop == "save":
						if not save:
							save = true
							emit_signal("state_changed")
						auto_heal = auto_heal / 2
					elif tile_prop == "speed":
						checkSave()
						if not speed:
							speed = true
							move_speed = move_speed*2
							
							tween.interpolate_property(camera, "zoom", camera_zoom, Vector2((camera_zoom.x + 1), (camera_zoom.y + 1)), 0.5, 7, 1)
							tween.start()
							PlaySound("speed")
							emit_signal("state_changed")
					elif tile_prop == "nospeed":
						checkSave()
						if speed:
							speed = false
							move_speed = move_speed/2
							
							tween.interpolate_property(camera, "zoom", Vector2((camera_zoom.x + 1), (camera_zoom.y + 1)), camera_zoom, 0.5, 7, 1)
							tween.start()
							emit_signal("state_changed")
					elif tile_prop == "finish":
						exit("finish")
				else:
					checkSave()
			elif tile < 0 and not timer:
				timer = true
				timer_progressbar.set_self_opacity(0.5)
				tween_timer.interpolate_property(timer_progressbar, "range/value", 0, 800, 4, 0, 1)
				tween_timer.start()
				tween_timer.connect("tween_complete", self, "die")


#####################=INPUT=####################
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		make_input_local(event)
		mouse_pos = event.pos - get_viewport_rect().size/2
	
	if event.is_action_pressed("state_switch") and not dead:
		ModeSwitch()
	
	if event.is_action_pressed("show_dbg"):
		debug = !debug
	
	if debug:
		if event.is_action_pressed("ui_accept") and not get_node("../Game Menu").menu_shown:
			exit("next_level")


####################=STATES=####################
func check_mode():
	if mode == 0:
		quarsh_no_state()
	if mode == 1:
		quarsh_state()

func quarsh_attack(body):
	if body.has_method("add_health") and not dead and not save:
		body.add_health(-quarsh_damage)


func quarsh_state():
	mode = 1
	get_node("/root/game/hud/hud").set_mode("quarsh")
	if not animation_player.get_current_animation() == "to_normal":
		setTrail(true, "Trail Quarsh")
		
	set_bounce(1)
	set_gravity_scale(0)
	set_linear_damp(0)
	var shape = shape3
	if small:
		set_mass(5)
		shape = shape4
	else:
		set_mass(10)
	get_node("shape").set_shape(shape)
	if not is_connected("body_enter", self, "quarsh_attack"):
		connect("body_enter", self, "quarsh_attack")
	get_node("Quarsh/QuarshAnim").play("idle")
	emit_signal("state_changed")

func quarsh_no_state():
	mode = 0
	get_node("/root/game/hud/hud").set_mode("normal")
	setTrail(true, "Trail")
	set_bounce(0.5)
	set_gravity_scale(3)
	set_linear_damp(2)
	var shape = shape1
	if small:
		set_mass(0.5)
		shape = shape2
	else:
		set_mass(1)
	get_node("shape").set_shape(shape)
	if is_connected("body_enter", self, "quarsh_attack"):
		disconnect("body_enter", self, "quarsh_attack")
	get_node("Quarsh/QuarshAnim").stop()
	emit_signal("state_changed")


func small_state():
	small = true
	check_mode()

func normal_state():
	small = false
	check_mode()


func stateSpeed(var color = true):
	animation_player.get_animation("to_small").track_set_key_value(3, 0, Vector2((camera_zoom.x*2 + 1), (camera_zoom.y*2 + 1)))
	animation_player.get_animation("to_small").track_set_key_value(3, 1, Vector2((camera_zoom.x + 1), (camera_zoom.y + 1)))
	animation_player.get_animation("to_normal").track_set_key_value(3, 0, Vector2((camera_zoom.x/2 + 1), (camera_zoom.y/2 + 1)))
	animation_player.get_animation("to_normal").track_set_key_value(3, 1, Vector2((camera_zoom.x + 1), (camera_zoom.y + 1)))
	
	animation_player.get_animation("enter").track_set_key_value(1, 1, Vector2((camera_zoom.x + 1), (camera_zoom.y + 1)))
	animation_player.get_animation("exit").track_set_key_value(2, 0, Vector2((camera_zoom.x + 1), (camera_zoom.y + 1)))
	animation_player.get_animation("exit").track_set_key_value(2, 1, (camera_zoom/2))
	
	if color:
		if not dead and can_move:
			setColor(speed_color, true, speed_canvas)
			particles.set_emitting(false)
		elif dead and not can_move and mode != 1:
			color_mode = death_color
			sprite.set_modulate(death_color)


func stateNospeed():
	animation_player.get_animation("to_small").track_set_key_value(3, 0, Vector2(camera_zoom*2))
	animation_player.get_animation("to_small").track_set_key_value(3, 1, Vector2(camera_zoom))
	animation_player.get_animation("to_normal").track_set_key_value(3, 0, Vector2(camera_zoom/2))
	animation_player.get_animation("to_normal").track_set_key_value(3, 1, Vector2(camera_zoom))
	
	animation_player.get_animation("enter").track_set_key_value(1, 1, camera_zoom)
	animation_player.get_animation("exit").track_set_key_value(2, 0, camera_zoom)
	animation_player.get_animation("exit").track_set_key_value(2, 1, (camera_zoom/2))
	
	setColor(normal_color, true)
	particles.set_emitting(false)


func stateSmall():
	camera_zoom = Vector2(2, 2)
	animation_player.get_animation("enter").track_set_key_value(0, 1, Vector2(0.5, 0.5))
	animation_player.get_animation("enter").track_set_key_value(1, 1, camera_zoom)
	animation_player.get_animation("exit").track_set_key_value(2, 0, camera_zoom)
	animation_player.get_animation("exit").track_set_key_value(2, 1, (camera_zoom/2))


func stateNosmall():
	camera_zoom = Vector2(4, 4)
	animation_player.get_animation("enter").track_set_key_value(0, 1, Vector2(1, 1))
	animation_player.get_animation("enter").track_set_key_value(1, 1, camera_zoom)
	animation_player.get_animation("exit").track_set_key_value(2, 0, camera_zoom)
	animation_player.get_animation("exit").track_set_key_value(2, 1, (camera_zoom/2))


func stateSave():
	var alpha = 1
	if mode != 1:
		alpha = 0.1
	setColor(save_color, false, save_canvas, alpha)
	particles.set_color(Color(0.6, 0.3, 0.1))
	particles.set_emitting(true)