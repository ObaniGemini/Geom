extends StaticBody2D

export(PackedScene) var bullet_scene
export var turning = false

onready var sample_player = get_node("SamplePlayer2D")
onready var animation_player = get_node("AnimationPlayer")
onready var timer = get_node("Timer")

var can_shoot_down = true
var can_shoot_up = true
var can_shoot_left = true
var can_shoot_right = true

func turret_shoot():
	var player_pos = get_node("/root/game/player").get_pos()
	var player_to_turret = Vector2(abs(player_pos.x - get_pos().x), abs(player_pos.y - get_pos().y))
	
#### A way to reduce lag on maps with great amounts of turrets
	if player_to_turret.x < 1600 or player_to_turret.y < 1400:
		if save_manager.config['sounds']:
			sample_player.play("bullet_turret")
		
		if not turning:
			if can_shoot_down:
				shoot(Vector2(0, 1))
			if can_shoot_up:
				shoot(Vector2(0, -1))
			if can_shoot_left:
				shoot(Vector2(-1, 0))
			if can_shoot_right:
				shoot(Vector2(1, 0))
		else:
			var rot = get_rot()
			for i in range(4):
				var dir = i*(PI/2) + rot + PI/8
				shoot(Vector2(cos(dir), -sin(dir)))
			timer.start()
	if not turning:
		animation_player.play("idle")

func shoot(direction):
	var new_bullet = bullet_scene.instance()
	var velocity = direction*new_bullet.speed
	
	new_bullet.set_pos(get_pos() + direction*100)
	new_bullet.set_linear_velocity(velocity)
	new_bullet.set_bullet_type("red")
	
	get_node("../../").add_child(new_bullet)

#######################=READY=######################
func _ready():
	if not turning:
		if get_node("rays/down").is_colliding():
			can_shoot_down = false
		if get_node("rays/up").is_colliding():
			can_shoot_up = false
		if get_node("rays/left").is_colliding():
			can_shoot_left = false
		if get_node("rays/right").is_colliding():
			can_shoot_right = false
		
		if save_manager.pack == "X":
			animation_player.set_speed(1.5)
		animation_player.play("idle")
		animation_player.connect("finished", self, "turret_shoot")
	else:
		timer.start()
		timer.connect("timeout", self, "turret_shoot")
		animation_player.play("idle2")

func die():
	if animation_player.is_connected("finished", self, "turret_shoot"):
		animation_player.disconnect("finished", self, "turret_shoot")
	animation_player.play("die")
	animation_player.connect("finished", self, "queue_free")