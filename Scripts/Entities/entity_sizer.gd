extends Area2D

const player_class = preload("res://Scripts/Base/player.gd")
var checked = false

onready var player = get_node("/root/game/player")

onready var animation_player = get_node("AnimationPlayer")
onready var timer = get_node("Timer")

onready var game_scene = get_node("/root/game")

onready var center = get_node("Center")
onready var triangle1 = get_node("Triangles/Triangle1")
onready var triangle3 = get_node("Triangles/Triangle3")
onready var triangle2 = get_node("Triangles/Triangle2")
onready var triangle4 = get_node("Triangles/Triangle4")

#######################=READY=######################
func _ready():
	if player.small:
		to_normal_state()
	else:
		to_small_state()
	connect("body_enter", self, "_on_body_enter")
	timer.connect("timeout", self, "connect", ["body_enter", self, "_on_body_enter"])
	
	set_process(true)

######################=PROCESS=#####################
func _process(delta):
	if player.small:
		to_normal_state()
	else:
		to_small_state()

func _on_body_enter(body):
	if body extends player_class:
		if not body.dead:
			if timer.get_time_left() <= 0:
				disconnect("body_enter", self, "_on_body_enter")
				if body.small:
					body.get_node("AnimationPlayer").play("to_normal")
					body.PlaySound("to_normal")
					body.normal_state()
				else:
					body.get_node("AnimationPlayer").play("to_small")
					body.PlaySound("to_small")
					body.small_state()
				timer.start()



func to_small_state():
	animation_player.set_speed(-1)
	triangle1.set_modulate(Color(0.6, 0.8, 0.7))
	triangle3.set_modulate(Color(0.6, 0.8, 0.7))
	triangle2.set_modulate(Color(0.6, 0.7, 0.8))
	triangle4.set_modulate(Color(0.6, 0.7, 0.8))

func to_normal_state():
	animation_player.set_speed(1)
	triangle1.set_modulate(Color(0.7, 0.6, 0.6))
	triangle3.set_modulate(Color(0.7, 0.6, 0.6))
	triangle2.set_modulate(Color(0.8, 0.6, 0.7))
	triangle4.set_modulate(Color(0.8, 0.6, 0.7))