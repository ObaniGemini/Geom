extends RigidBody2D

const wall_detectors = ["wall_detector", "wall_detector1"]
const damage = 2.0

var time = 0.0
var clock = 0.0
var moving = 1
var damage_cooldown = 0.4

func _ready():
	get_node("Sprite").set_modulate(Color(rand_range(0.6, 1), rand_range(0.6, 1), rand_range(0.6, 1)))
	get_node("Sprite1").set_modulate(Color(rand_range(0.4, 0.8), rand_range(0.4, 0.8), rand_range(0.4, 0.8)))
	get_node("Particles2D").set_color(Color((randi()%5)*0.25, (randi()%5)*0.25, (randi()%5)*0.25))
	for detector in wall_detectors:
		get_node(detector).add_exception(self)
	set_fixed_process(true)
	set_rotd(45*(randi() % 8))

func _integrate_forces(state):
	state.set_linear_velocity(1500*moving*Vector2(cos(get_rot()), -sin(get_rot())))

func _fixed_process(delta):
	time += delta
	damage_cooldown -= delta
	
	if time > clock:
		set_rot(get_rot() + (PI/4)*(randi() % 3 - 1))
		var boolean = randi() % 8
		moving = 0
		if boolean > 0:
			moving = 1
		reset_clock()
	
	for node in wall_detectors:
		var detector = get_node(node)
		if detector.is_colliding():
			set_rot(get_rot() + PI + (PI/4)*(randi() % 3 - 1))
			reset_clock()


func reset_clock():
	clock = rand_range(0.3, 1.2)
	time = 0.0

func _on_body_enter(body):
	if body.get_name() == "player":
		if damage_cooldown <= 0:
			if not body.save:
				body.add_health(-damage)
				damage_cooldown = 0.4