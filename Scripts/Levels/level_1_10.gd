extends TileMap

onready var tween = get_node("event/Tween")

const turret_script = preload("res://Scripts/Enemies/enemy_quarsh_mini.gd")
const mini_quarsh_script = preload("res://Scripts/Enemies/enemy_turret.gd")

#######################=READY=######################
func _ready():
	get_node("enemy_quarsh").connect("die", self, "end")

func end():
	for child in get_children():
		if child extends turret_script or child extends mini_quarsh_script:
			child.die()
	
	for node in get_node("event/left").get_children():
		for block in node.get_children():
			tween.interpolate_property(block, "transform/pos", block.get_pos(), block.get_pos()-Vector2(256, 0), rand_range(0.4, 2), randi() % 3, 1)
			tween.start()
	
	for node in get_node("event/right").get_children():
		for block in node.get_children():
			tween.interpolate_property(block, "transform/pos", block.get_pos(), block.get_pos()+Vector2(256, 0), rand_range(0.4, 2), randi() % 3, 1)
			tween.start()
	
	save_manager.progression.quarsh_power = true