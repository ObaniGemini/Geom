extends RigidBody2D

func _ready():
	set_use_custom_integrator(true)


func _integrate_forces():
	set_angular_velocity(5)