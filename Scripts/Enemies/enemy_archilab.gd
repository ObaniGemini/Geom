extends RigidBody2D

const player_class = preload("res://Scripts/Base/player.gd")
var player_pos = Vector2(0, 0)
var detected = false
onready var tween = get_node("Tween")

var start_health = 30.0
var health = 0.0
var dead = false

var random_dir = 1
var cooldown = 3.0
var time = 0.0

func _ready():
	health = start_health
	set_fixed_process(true)

func _fixed_process(delta):
	player_pos = get_pos()
	for body in get_node("Area2D").get_overlapping_bodies():
		if body extends player_class and not dead:
			if not body.save:
				player_pos = body.get_pos()
				if not detected:
					detected = true
					random_dir = sign(rand_range(-1, 1))
					get_node("Particles2D").set_emitting(true)
	
	if player_pos == get_pos() and detected or dead:
		detected = false
		get_node("Particles2D").set_emitting(false)
	
	if detected and time < cooldown:
		time += delta
	elif not detected and time > 0:
		time -= delta
	
	var direction = (player_pos - get_pos()).normalized()
	set_pos(get_pos() + direction*5.5*(time/2)*(1 + 2*(1 - (health/start_health))))
	set_rot(get_rot() + 0.05*time*random_dir*(1 + (1 - (health/start_health))))
	if get_rot() >= 360:
		set_rot(0)

func add_health(amount):
	health += amount
	if health <= 0 and not dead:
		die()
	else:
		tween.interpolate_property(get_node("Sprite"), "modulate", Color(0.5,0.45,0.45), \
								Color((0.8-(1+(health/start_health))/2), \
								(0.8-0.8*(1+(health/start_health))/2), \
								(0.8-0.8*(1+(health/start_health))/2)), 0.2, 1, 1)
		tween.start()

func die():
	dead = true
	tween.stop_all()
	tween.interpolate_property(self, "visibility/opacity", 1, 0, 0.5, 0, 0)
	tween.start()
	yield(tween, "tween_complete")
	queue_free()