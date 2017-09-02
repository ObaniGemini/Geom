extends RigidBody2D

const player_class = preload("res://Scripts/Base/player.gd")
const damage = 1.0
const speed = 1000

var life_time = 1
var initial_time = 0.1

var dangerous = true
var dangerous_to_player = false
var this_class = get_script()
var bullet_type = "yellow"

onready var layer_mask = get_layer_mask()
onready var collision_mask = get_collision_mask()

onready var tween = get_node("Tween")
onready var trail = get_node("Trail")
onready var sprite = get_node("Sprite")

func _on_body_enter(body):
	var collisions = get_colliding_bodies()
	for body in collisions:
		if !body extends this_class and dangerous:
			if bullet_type == "red":
				if body extends player_class and dangerous:
					if !body.save:
						body.add_health(-damage*2)
						die()
			elif bullet_type == "light_blue":
				if body.has_method("add_health"):
					if !body extends player_class:
						body.add_health(-damage)
					else:
						if dangerous_to_player:
							body.add_health(damage)
				die()
			else:
				if body.has_method("add_health"):
					if !body extends player_class:
						body.add_health(-damage)
						die()
					else:
						if dangerous_to_player:
							body.add_health(-damage)
							die()

func dangerous(object, key):
	if key == "visibility/self_opacity":
		queue_free()
	else:
		trail.set_emitting(true)
		dangerous_to_player = true

func checkLifeTime():
	if life_time <= 0:
		die()

#######################=READY=######################
func _ready():
	connect("body_enter", self, "_on_body_enter")
	life_time = rand_range(1,1.2)
	
	tween.interpolate_property(sprite, "visibility/opacity", 0, 1, 0.1, 0, 1)
	tween.start()
	tween.connect("tween_complete", self, "dangerous")
	
	set_layer_mask(layer_mask)
	set_collision_mask(collision_mask)
	
	set_fixed_process(true)

###################=FIXED PROCESS=##################
func _fixed_process(delta):
	life_time = life_time - delta
	
	checkLifeTime()
	if initial_time != null:
		if initial_time <= 0:
			initial_time = null
			set_layer_mask(layer_mask)
			set_collision_mask(collision_mask)
		else:
			initial_time = initial_time - delta
	else:
		set_layer_mask(layer_mask)
		set_collision_mask(collision_mask)

func die():
	dangerous = false
	trail.set_emitting(false)
	set_layer_mask(16384)
	tween.interpolate_property(sprite, "visibility/self_opacity", 1, 0, 0.1, 0, 1)
	tween.start()


func set_bullet_type(color):
	if color == "red":
		bullet_type = "red"
		get_node("Sprite").set_modulate(Color(0.8, 0.5, 0.3))
		get_node("Trail").set_color(Color(0.7, 0.4, 0.2))
	elif color == "light_blue":
		bullet_type = "light_blue"
		set_gravity_scale(0)
		get_node("Sprite").set_modulate(Color(0.5, 0.6, 0.9))
		get_node("Trail").set_color(Color(0.4, 0.5, 0.8))
	elif color == "dark_blue":
		bullet_type = "dark_blue"
		get_node("Sprite").set_modulate(Color(0.2, 0.3, 0.7))
		get_node("Trail").set_color(Color(0.1, 0.2, 0.6))
	elif color == "yellow":
		bullet_type = "yellow"
		get_node("Sprite").set_modulate(Color(0.9, 0.8, 0.6))
		get_node("Trail").set_color(Color(0.8, 0.7, 0.5))