extends Area2D

func _on_body_enter(body):
	if body.get_name() == "player":
		if not body.dead:
			body.setHealth(body.start_health)
			body.PlaySound("star")
			resource_manager.add_resource_amount("stars", 1)
			
			disconnect("body_enter", self, "_on_body_enter")
			get_node("AnimationPlayer").play("take")
			yield(get_node("AnimationPlayer"), "finished")
			queue_free()