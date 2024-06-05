extends CharacterBody2D

## How fast does your character move?
@export_range(0, 1000, 10) var speed: float = 300.0

## How high does your character jump? Note that the gravity will
## be influenced by the [member GameLogic.gravity].
@export_range(-1000, 1000, 10) var jump_velocity = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.gravity_changed.connect(_on_gravity_changed)


func _on_gravity_changed(new_gravity):
	gravity = new_gravity


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
