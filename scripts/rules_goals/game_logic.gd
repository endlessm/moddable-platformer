class_name GameLogic
extends Node

# Keep default the same as ProjectSettings.get_setting("physics/2d/default_gravity")
## This is the gravity of the world. In pixels per second squared.
@export_range(-2000.0, 2000.0, 0.1, "suffix:px/s²") var gravity: float = 980.0


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	# Set the gravity strength at runtime:
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity
	)
	Global.gravity_changed.emit(gravity)
