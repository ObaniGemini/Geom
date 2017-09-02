extends StaticBody2D

export(PackedScene) var square_wave

onready var animation_player = get_node("AnimationPlayer")
onready var tween = get_node("Tween")
onready var body = get_node("Body")

func _ready():
	wave()

func wave():
	var player_pos = get_node("/root/game/player").get_pos()
	var player_to_turret = Vector2(abs(player_pos.x - get_pos().x), abs(player_pos.y - get_pos().y))
	var rot = get_rot() + PI/4
### A way to reduce lag on maps with great amounts of turrets
	if player_to_turret.x < 1600 or player_to_turret.y < 1400:
		rot += PI/4
		if rot == 2*PI:
			rot = 0
		shoot(rot)
		shoot(rot+PI)
	set_rot(rot - PI/4)
	animation_player.play("idle")

func shoot(rot):
	var shoot = square_wave.instance()
	shoot.set_rot(-rot)
	shoot.get_node("Sprite").set_modulate(Color(rand_range(0.2, 0.4), rand_range(0.4, 0.6), rand_range(0.6, 0.8), 0.8))
	tween.interpolate_property(shoot, "transform/pos", get_pos(), Vector2(get_pos().x + cos(rot)*1200, get_pos().y + sin(rot)*1200), 0.8, 1, 1)
	tween.start()
	get_parent().call_deferred("add_child", shoot)