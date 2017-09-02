extends Node2D

var melody = false

func PlaySound(sound):
	if save_manager.config['melody']:
		show()
		get_node("SamplePlayer").play(sound)
	else:
		hide()

func stop_all():
	for child in get_children():
		stop(child.get_name())

func stop(node):
	if get_node(node) extends Sprite:
		var node_anim = get_node(node).get_node("AnimationPlayer")
		if node_anim.is_connected("finished", self, "set_position"):
			node_anim.disconnect("finished", self, "set_position")
	if get_node(node) extends Particles2D:
		var node_timer = get_node(node).get_node("Timer")
		if node_timer.is_connected("timeout", self, "set_position"):
			node_timer.disconnect("timeout", self, "set_position")

func set_position(node, random, random_sound):
	var choice = randi()% random + 1
	var object = get_node(node)
	
	if node == 'rectangle':
		object.set_rot(randi()% 180)
	
	if object extends Particles2D:
		var timer = object.get_node("Timer")
		if not timer.is_connected("timeout", self, "set_position"):
			timer.connect("timeout", self, "set_position", ['firework', 2, 5])
		timer.start()
		if choice == 1:
			object.show()
			object.set_emitting(true)
			object.set_pos(Vector2(rand_range(0, 2600), rand_range(200, 1400)))
			object.set_color_phase_color(0, Color(rand_range(1, 0.1), rand_range(1, 0.1), rand_range(1, 0.1), 0.75))
			object.set_color_phase_color(1, Color(rand_range(1, 0.1), rand_range(1, 0.1), rand_range(1, 0.1), 0))
			PlaySound(str(node+str(randi()% 5 + 1)))
		else:
			object.hide()
	else:
		var animation_player = object.get_node("AnimationPlayer")
		var anim_name = str(node, "_wave")
		if not animation_player.is_connected("finished", self, "set_position"):
			animation_player.connect("finished", self, "set_position", [node, random, random_sound])
		if choice == 1:
			object.show()
			animation_player.play(anim_name)
			PlaySound(node+str(randi()% random_sound + 1))
			if animation_player.get_current_animation() == anim_name:
				object.set_pos(Vector2(rand_range(0, 2600), rand_range(200, 1400)))
				object.set_modulate(Color(rand_range(1, 0.5), rand_range(1, 0.5), rand_range(1, 0.5), 0.8))
		else:
			object.hide()
			animation_player.play(anim_name)