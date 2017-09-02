extends Control

export(NodePath) var player_path = "/root/game/player"

var health_initial_region
var health_percent_1

var health_initial_color
var health_color_percent_1
var health_color_percent_2

var health_sprites
var all_sprites = []

onready var health = get_node("Game/health")
onready var tween = get_node("Tween")
onready var stars_label = get_node("Game/stars/label")

onready var player = get_node(player_path)

#######################=READY=######################
func _ready():
	health_sprites = get_node("Game/health/normal")
	for node in get_node("Game/health").get_children():
		for child in node.get_children():
			all_sprites.append(child)
	health_initial_region = get_node("Game/health/normal/Sprite").get_scale()
	health_initial_color = get_node("Game/health/normal/Sprite").get_modulate()
	
	health_percent_1 = health_initial_region
	health_color_percent_1 = health_initial_color
	
	player.connect("health_changed", self, "update_health_values")
	player.connect("state_changed", self, "update_health_color")
	resource_manager.connect("amount_changed", self, "update_stars_values")

func update_health_color(amount=1):
	tween.stop_all()
	set_health_color()
	for sprite in all_sprites:
		tween.interpolate_property(sprite, "modulate", health_color_percent_1, health_color_percent_2, 0.15*((3+amount)/4), 1, 1)
		tween.start()
	health_color_percent_1 = health_color_percent_2

func update_health_scale(amount):
	var health_percent_2 = health_initial_region*Vector2((player.health / player.start_health),(player.health / player.start_health))
	for sprite in all_sprites:
		tween.interpolate_property(sprite, "transform/scale", health_percent_1, health_percent_2, 0.15*((3+amount)/4), 1, 1)
		tween.start()
	health_percent_1 = health_percent_2

func update_health_values(amount = 1):
	update_health_color(amount)
	update_health_scale(amount)

func set_health_color():
	if player.save and player.can_move:
		health_initial_color = player.save_color
		health_color_percent_2 = Color(health_initial_color.r + 0.3 - 0.3*(player.health / player.start_health), health_initial_color.g - 0.35 + 0.35*(player.health / player.start_health), health_initial_color.b - 0.1 + 0.1*(player.health / player.start_health))
	elif player.speed:
		health_initial_color = player.speed_color
		health_color_percent_2 = Color(health_initial_color.r, health_initial_color.g - 0.35 + 0.35*(player.health / player.start_health), health_initial_color.b - 0.6 + 0.6*(player.health / player.start_health))
	else:
		health_initial_color = player.normal_color
		health_color_percent_2 = Color(health_initial_color.r + 0.2 - 0.2*(player.health / player.start_health), health_initial_color.g - 0.55 + 0.55*(player.health / player.start_health), health_initial_color.b - 0.2 + 0.2*(player.health / player.start_health))

func update_stars_values(var variable = null):
	var stars = resource_manager.get_resource_amount("stars")
	stars_label.set_text(str("x ", stars))
	get_node("Game/stars/Tween").interpolate_property(get_node("Game/stars/Sprite"), "transform/rot", 0, 144, 0.5, 1, 1)
	get_node("Game/stars/Tween").start()

func set_mode(mode):
	health_sprites.hide()
	health_sprites = get_node(str("Game/health/", mode))
	health_sprites.show()

func show_game_hud():
	tween.interpolate_property(get_node("Game/stars"), "rect/pos", Vector2(10, -108), Vector2(10, 40), 0.5, 1, 1)
	tween.start()
	get_node("Game/health").show()
	

func hide_game_hud():
	tween.interpolate_property(get_node("Game/stars"), "rect/pos", Vector2(10, 40), Vector2(10, -108), 0.5, 1, 1)
	tween.start()
	get_node("Game/health").hide()