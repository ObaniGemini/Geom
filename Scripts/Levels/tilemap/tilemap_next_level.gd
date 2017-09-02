extends Node2D

func _ready():
	for node in get_children():
		if node extends Area2D:
			node.connect("body_enter", get_node("/root/game/player"), "exit", ["next_level"])