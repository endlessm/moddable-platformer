@tool
extends CharacterBody2D

## Use this to change the sprite frames of your character.
@export var sprite_frames: SpriteFrames = _initial_sprite_frames:
	set = _set_sprite_frames

## How fast does your character move?
@export_range(0, 1000, 10, "suffix:px/s") var speed: float = 500.0:
	set = _set_speed

## How high does your character jump? Note that the gravity will
## be influenced by the [member GameLogic.gravity].
@export_range(-1000, 1000, 10, "suffix:px/s") var jump_velocity = -880.0

## How much should the character's jump be reduced if you let go of the jump
## key before the top of the jump? [code]0[/code] means “not at all”;
## [code]100[/code] means “upwards movement completely stops”.
@export_range(0, 100, 5, "suffix:%") var jump_cut_factor: float = 20

## How long after the character walks off a ledge can they still jump?
## This is often set to a small positive number to allow the player a little
## margin for error before they start falling.
@export_range(0, 0.5, 1 / 60.0, "suffix:s") var coyote_time: float = 5.0 / 60.0

## If the character is about to land on the floor, how early can the player
## the jump key to jump as soon as the character lands? This is often set to
## a small positive number to allow the player a little margin for error.
@export_range(0, 0.5, 1 / 60.0, "suffix:s") var jump_buffer: float = 5.0 / 60.0

# If positive, the player is either on the ground, or left the ground less than this long ago
var coyote_timer: float = 0

# If positive, the player pressed jump this long ago
var jump_buffer_timer: float = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var original_position: Vector2

@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _initial_sprite_frames: SpriteFrames = %AnimatedSprite2D.sprite_frames


func _set_sprite_frames(new_sprite_frames):
	sprite_frames = new_sprite_frames
	if sprite_frames and is_node_ready():
		_sprite.sprite_frames = sprite_frames


func _set_speed(new_speed):
	speed = new_speed
	if not is_node_ready():
		await ready
	if speed == 0:
		_sprite.speed_scale = 0
	else:
		_sprite.speed_scale = speed / 500


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
	else:
		Global.gravity_changed.connect(_on_gravity_changed)
		Global.lives_changed.connect(_on_lives_changed)

	original_position = position
	_set_speed(speed)
	_set_sprite_frames(sprite_frames)


func _on_gravity_changed(new_gravity):
	gravity = new_gravity


func _physics_process(delta):
	# Don't move if there are no lives left.
	if Global.lives <= 0:
		return

	# Handle jump
	if is_on_floor():
		coyote_timer = (coyote_time + delta)

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = (jump_buffer + delta)

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		coyote_timer = 0
		jump_buffer_timer = 0

	# Reduce velocity if the player lets go of the jump key before the apex.
	# This allows controlling the height of the jump.
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= (1 - (jump_cut_factor / 100.00))

	# Add the gravity.
	if coyote_timer <= 0:
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if velocity == Vector2.ZERO:
		_sprite.play("idle")
	else:
		if not is_on_floor():
			if velocity.y > 0:
				_sprite.play("jump_down")
			else:
				_sprite.play("jump_up")
		else:
			_sprite.play("walk")
		_sprite.flip_h = velocity.x < 0

	move_and_slide()

	coyote_timer -= delta
	jump_buffer_timer -= delta


func reset():
	position = original_position
	velocity = Vector2.ZERO
	coyote_timer = 0
	jump_buffer_timer = 0


func _on_lives_changed():
	if Global.lives > 0:
		reset()
