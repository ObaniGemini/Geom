extends Area2D

const player_class = preload("res://Scripts/Base/player.gd")
var checked = false
var checkpoint_image
var mode = 1

var particles
var sprite

onready var player = get_node("/root/game/player")
onready var animation_player = get_node("AnimationPlayer")

func _on_body_enter(body):
	if body extends player_class:
		if not checked:
			checked = true
			set_process(true)
			
			body.setCheckpoint(self)
			body.setHealth(body.start_health)
			
			sprite.set_modulate(Color(0.7, 0.9, 0.3))
			animation_player.set_speed(-8)
			body.PlaySound("checkpoint")
		body.auto_heal_time /= 4
		particles.set_emitting(true)

func _on_body_exit(body):
	if body extends player_class:
		body.auto_heal_time *= 4
		particles.set_emitting(false)

#######################=READY=######################
func _ready():
	if save_manager.pack == "2":
		animation_player.get_animation("rotation").track_remove_key(0, 1)
		animation_player.get_animation("rotation").set_length(4)
		animation_player.get_animation("rotation").track_insert_key(0, 4, 360)
		mode = 2
	
	particles = get_node(str(str(mode), "/Particles"))
	sprite = get_node(str(str(mode), "/Sprite"))
	animation_player.get_animation("rotation").track_set_path(0, str(str(mode), "/Sprite:transform/rot"))
	
	for node in get_children():
		if node extends Node2D and node.get_name() != str(mode):
			for graphics in node.get_children():
				graphics.hide()
	
	animation_player.play("rotation")

######################=PROCESS=#####################
func _process(delta):
	if player.last_checkpoint != self and checked:
		checked = false
		sprite.set_modulate(Color(1, 1, 1))
		animation_player.set_speed(1)
		set_process(false)