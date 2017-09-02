extends RigidBody2D

const player_class = preload("res://Scripts/Base/player.gd")
const star_class = preload("res://Scenes/Entities/entity_star.tscn")
const start_health = 5.0

var modulation

var health = 1.0
var damage = 1.0

var dead = false

onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")
onready var tween = get_node("Tween")

func _on_body_enter(body):
	if timer.get_time_left() <= 0:
		if body extends player_class:
			if body.get("save") == null or !body.save:
				body.add_health(-damage)
				timer.start()
				set_modulate()

func add_health(var amount):
	var velocity = get_linear_velocity()
	health += amount
	
	if health <= 0 and not dead:
		dead = true
		tween.stop_all()
		disconnect("body_enter", self, "_on_body_enter")
		
		get_node("Particles2D").set_emitting(true)
		
		tween.interpolate_property(sprite, "visibility/opacity", 1, 0, 0.4, 1, 1)
		tween.start()
		tween.connect("tween_complete", self, "die")
	else:
		tween.interpolate_property(sprite, "modulate", Color(0.5, 0.4, 1), modulation, 0.5, 1, 1)
		tween.start()

func set_modulate():
	modulation = Color(rand_range(0.3, 0.6), rand_range(0.3, 0.6), rand_range(0.3, 0.6))
	sprite.set_modulate(modulation)
	get_node("Particles2D").set_color(modulation)

#######################=READY=######################
func _ready():
	health = start_health
	set_modulate()

func die(object=null, key=null):
	var star = star_class.instance()
	star.set_pos(get_pos())
	get_parent().add_child(star)
	queue_free()