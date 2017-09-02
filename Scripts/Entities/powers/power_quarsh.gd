extends Area2D

export(PackedScene) var acquire

const player_class = preload("res://Scripts/Base/player.gd")

onready var sprite = get_node("Sprite")
onready var sprite2 = get_node("Sprite2")
onready var tween = get_node("Tween")

func _on_body_enter(body):
	if body extends player_class:
		if body.can_move:
			body.can_move = false
			
			var acquire_power = acquire.instance()
			body.add_child("acquire_power")
			
			tween.interpolate_property(sprite, "transform/scale", 0, 0.8, 1, 1)
			tween.start()
			tween.interpolate_property(sprite2, "transform/scale", 0, 0.8, 1, 1)
			tween.start()
			
			tween.connect("tween_complete", self, "die")

func _ready():
	tween.interpolate_property(sprite, "transform/scale", 0, 0.8, 1, 1)
	tween.start()
	tween.interpolate_property(sprite2, "transform/scale", 0, 0.8, 1, 1)
	tween.start()
	
	connect("body_enter", self, "_on_body_enter")

func die(object, key):
	queue_free()