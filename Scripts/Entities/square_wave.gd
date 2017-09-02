extends Area2D

var dangerous = true

func hurt(body):
	if body.get_name() == "player" and dangerous:
		if not body.save and not body.dead:
			body.add_health(-1, 2)
			dangerous = false