extends Area2D

var up = ["", "6", "7", "1"]
var left = ["4", "10", "11", "5", "16", "17", "18", "19"]
var right = ["2", "8", "9", "3", "12", "13", "14", "15"]
var taken = false

func _on_body_enter(body):
	if body.get_name() == "player" and not taken:
		taken = true
		save_manager.progression.bullet_type = "light_blue"
		get_node("AnimationPlayer").play("taken")
		
		yield(get_node("AnimationPlayer"), "finished")
		
		get_node("../decor").set_z(1)
		resource_manager.set_resource_amount("enemies", 0)
		for node in get_node("../enemies").get_children():
			resource_manager.add_resource_amount("enemies", node.get_child_count())
			for enemy in node.get_children():
				enemy.connect("die", get_parent(), "update_deaths")

		for node in get_node("../event").get_children():
			for name in up:
				if node.get_name() == str("block" + name):
					node.set_one_way_collision_direction(Vector2(0, -1))
			for name in left:
				if node.get_name() == str("block" + name):
					node.set_one_way_collision_direction(Vector2(-1, 0))
			for name in right:
				if node.get_name() == str("block" + name):
					node.set_one_way_collision_direction(Vector2(1, 0))
			node.set_one_way_collision_max_depth(2)
		
		queue_free()