extends RigidBody2D

signal die()

const player_class = preload("res://Scripts/Base/player.gd")
const start_health = 6.0
const speed = 45.0
const damage = 1.0

var move_speed = 1.0

var damage_cooldown = 0.5
var damage_cooldown_left = 0.0

var detected = false
var dead = false

var health = 1.0

onready var sprite = get_node("Sprite")
onready var sense_area = get_node("SenseArea")

onready var sample_player = get_node("SamplePlayer2D")
onready var animation_player = get_node("AnimationPlayer")

func _on_body_enter(body):
	if body extends player_class:
		if damage_cooldown_left <= 0:
			if !body.save:
				body.add_health(-damage)
				damage_cooldown_left = damage_cooldown

func add_health(var amount):
	health += amount
	sprite.set_modulate(Color((((health/start_health)+3)/4), (((health/start_health)*2+1)/3), (((health/start_health)*2+1)/3)))
	if health <= 0 and not dead:
		die()

#######################=READY=######################
func _ready():
	health = start_health
	
	animation_player.play("rotation")
	animation_player.set_speed(-1)
	connect("body_enter", self, "_on_body_enter")
	
	set_fixed_process(true)

###################=FIXED PROCESS=##################
func _fixed_process(delta):
	damage_cooldown_left -= delta
	move_speed = (speed*5)/(2+(health/start_health)*3)
	
	var player_positions = Vector2Array()
	for body in sense_area.get_overlapping_bodies():
		if body extends player_class and !body.save:
			player_positions.push_back(body.get_pos() - get_pos())
	var direction = Vector2(0,0)
	
	if dead:
		animation_player.set_speed(4)
	else:
		if player_positions.size() <= 0:
			if detected:
				detected = false
				animation_player.set_speed(-1)
			direction = (Vector2(0.3, 0.3)).rotated(rand_range(0, PI*2))
		else:
			for position in player_positions:
				if not detected:
					detected = true
					animation_player.set_speed(4)
				direction += position + Vector2(rand_range(-20,20),rand_range(-20,20))
			direction /= player_positions.size()
			direction = direction.normalized()
		
		set_linear_velocity(direction*move_speed + get_linear_velocity())

func die():
	dead = true
	if save_manager.config['sounds']:
		sample_player.play("enemy_gear_death")
	animation_player.play("die")
	animation_player.connect("finished", self, "queue_free")
	emit_signal("die")