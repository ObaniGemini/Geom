extends TileMap

func update_deaths():
	resource_manager.add_resource_amount("enemies", -1)
	if resource_manager.get_resource_amount("enemies") <= 0:
		for block in get_node("anim").get_children():
			get_node("Tween").interpolate_property(block, "transform/pos", block.get_pos(), block.get_pos() + Vector2(0, 256), rand_range(0.5, 2), randi() % 3, 1)
			get_node("Tween").start()