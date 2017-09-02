extends Node2D

func _ready():
	for node in get_children():
		if node extends Area2D:
			node.connect("body_enter", self, "kill")

func kill(body):
	if body.get_name() == "player":
		if body.respawn_timer <= 0 and body.mode != 1 and not body.dead:
			body.die()