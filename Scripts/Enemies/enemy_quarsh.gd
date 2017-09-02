extends RigidBody2D

signal die()

export(PackedScene) var quarsh_mini

const player_class = preload("res://Scripts/Base/player.gd")
const start_health = 40.0

var health = 1.0
var damage = -2.0

var random_nuance = rand_range(0.5, 0.7)
var random_orientation = randi()% 2001

var dead = false

onready var trail = get_node("Trail")
onready var sprite = get_node("Sprite")

onready var animation_player = get_node("AnimationPlayer")
onready var tween = get_node("Tween")

onready var timer = get_node("Timer")
onready var spawn_timer = get_node("SpawnTimer")

func _on_body_enter(body):
	if timer.get_time_left() <= 0:
		if body extends player_class:
			if body.get("save") == null or !body.save:
				body.add_health(damage)
				randomize_color()
				timer.start()

func randomize_color():
	trail.set_color_phase_color(0, Color(rand_range(0.4, 0.8), rand_range(0.4, 0.8), rand_range(0.4, 0.8)))
	trail.set_color_phase_color(1, Color(rand_range(0.4, 0.8), rand_range(0.4, 0.8), rand_range(0.4, 0.8), 0))


func add_health(var amount):
	var velocity = get_linear_velocity()
	var damage_nuance = Color((random_nuance*(((health/start_health)+2)/3)), \
							(random_nuance*(((health/start_health)*3+1)/4)), \
							(random_nuance*(((health/start_health)*3+1)/4)))
	
	health += amount
	
	if health <= 0 and not dead:
		dead = true
		tween.stop_all()
		disconnect("body_enter", self, "_on_body_enter")
		
		tween.interpolate_property(self, "velocity/linear", velocity, Vector2(0, 0), 1.5, 1, 1)
		tween.start()
		
		animation_player.play("die")
		animation_player.connect("finished", self, "die")
		
		yield(animation_player, "finished")
		emit_signal("die")
		queue_free()
	else:
		set_linear_velocity((velocity*3)/(health/start_health+2))
		sprite.set_modulate(damage_nuance)
		
		tween.interpolate_property(sprite, "modulate", Color(((randi()%2)*0.4), ((randi()%2)*0.4), ((randi()%2)*0.4)), damage_nuance, 0.5, 1, 1)
		tween.start()

func add_quarsh_mini():
	var new_quarsh_mini = quarsh_mini.instance()
	
	new_quarsh_mini.set_pos(get_pos())
	new_quarsh_mini.set_linear_velocity(get_linear_velocity())
	
	if save_manager.config['sounds']:
		get_node("SamplePlayer2D").play(str("quarsh_spawn", str(randi()% 3 + 1)))
	get_parent().add_child(new_quarsh_mini)

#######################=READY=######################
func _ready():
	health = start_health
	
	sprite.set_modulate(Color(random_nuance, random_nuance, random_nuance))
	randomize_color()
	set_linear_velocity(Vector2((2000 - random_orientation), (random_orientation - 2000)))
	
	connect("body_enter", self, "_on_body_enter")
	spawn_timer.connect("timeout", self, "add_quarsh_mini")
	set_process(true)

func _process(delta):
	if abs(get_pos().y+get_node("../spawn").get_pos().y) > 40000 or abs(get_pos().x+get_node("../spawn").get_pos().x) > 40000: 
		add_health(-40.0)