extends Area2D

const player_class = preload("res://Scripts/Base/player.gd")

var pack
var part2 = false
var loaded = false

onready var animation_player = get_node("AnimationPlayer")

onready var sprite1 = get_node("Sprite1")
onready var sprite2 = get_node("Sprite2")

onready var sprite1_color = sprite1.get_modulate()
onready var sprite2_color = sprite2.get_modulate()

#######################=READY=######################
func _ready():
	if get_name() == "loader_pack1":
		pack = "1"
	elif get_name() == "loader_pack2":
		pack = "2"
	elif get_name() == "loader_packX":
		pack = "X"

func _on_body_enter(body):
	if body extends player_class and not loaded:
		loaded = true
		body.can_move = false
		body.can_switch = false
		body.setMode(0)
		body.PlaySound("next_level")
		body.get_node("AnimationPlayer").play("exit")
		body.get_node("AnimationPlayer").connect("finished", body.get_parent(), "load_level", [pack, 1], 4)

func idle():
	part2 =! part2
	if part2:
		sprite1.set_modulate(sprite2_color)
		sprite2.set_modulate(sprite1_color)
	else:
		sprite1.set_modulate(sprite1_color)
		sprite2.set_modulate(sprite2_color)
	animation_player.play("idle")