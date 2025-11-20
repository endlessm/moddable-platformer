@tool
class_name Player
extends CharacterBody2D
## A player's character, which can walk, jump, and stomp on enemies.

## The player-character's maximum downwards speed while gliding.
## Making this number smaller allows the player to glide further.
## [br][br]
## Used by [method _glide].
const GLIDE_TERMINAL_VELOCITY = 100

## How many pixels the player-character should teleport horizontally when the
## teleport special ability is used.
## [br][br]
## Used by [method _teleport].
const TELEPORT_DISTANCE = 512

## How much to scale [member jump_velocity] when the player-character is shrunk. Setting this close
## to or below [code]0[/code] prevents jumping; setting this to [code]1[/code] or greater causes
## jumps while shrunk to be the same as normal size.
## [br][br]
## Used by [method _shrink].
const JUMP_VELOCITY_SCALE_WHEN_SMALL = 0.85

## Which player controls this character?
@export var player: Global.Player = Global.Player.ONE

## Use this to change the sprite frames of your character.
@export var sprite_frames: SpriteFrames = _initial_sprite_frames:
	set = _set_sprite_frames

## How fast does your character move?
@export_range(0, 1000, 10, "suffix:px/s") var speed: float = 500.0:
	set = _set_speed

## How fast does your character accelerate?
@export_range(0, 5000, 1000, "suffix:px/s²") var acceleration: float = 5000.0

## How high does your character jump? Note that the gravity will
## be influenced by the [member GameLogic.gravity].
@export_range(0, 2000, 10, "suffix:px/s") var jump_velocity = 880.0

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

## Can your character jump a second time while still in the air?
@export var double_jump: bool = false

# If positive, the player is either on the ground, or left the ground less than this long ago
var coyote_timer: float = 0

# If positive, the player pressed jump this long ago
var jump_buffer_timer: float = 0

# If true, the player is already jumping and can perform a double-jump
var double_jump_armed: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var original_position: Vector2

# Whether the player-character is currently shrunk. See _shrink().
var _is_shrunk := false

@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _initial_sprite_frames: SpriteFrames = %AnimatedSprite2D.sprite_frames
@onready var _double_jump_particles: CPUParticles2D = %DoubleJumpParticles

@onready var _jump_sfx: AudioStreamPlayer = %JumpSFX
@onready var _glide_sfx: AudioStreamPlayer = %GlideSFX
@onready var _teleport_sfx: AudioStreamPlayer = %TeleportSFX


func _set_sprite_frames(new_sprite_frames):
	sprite_frames = new_sprite_frames
	if sprite_frames and is_node_ready():
		_sprite.sprite_frames = sprite_frames


func _set_speed(new_speed):
	speed = new_speed
	if is_node_ready():
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


func _jump():
	velocity.y = -jump_velocity
	coyote_timer = 0
	jump_buffer_timer = 0
	if double_jump_armed:
		double_jump_armed = false
		_double_jump_particles.emitting = true
	elif double_jump:
		double_jump_armed = true
	_jump_sfx.play()


func stomp():
	double_jump_armed = false
	_jump()


## If the player-character is in the air, and the "jump" action is held, clamp the downwards
## velocity to a constant. Must be called after applying gravity to the player-character.
func _glide() -> void:
	if not is_on_floor() and Input.is_action_pressed(Actions.lookup(player, "jump")):
		if velocity.y > GLIDE_TERMINAL_VELOCITY:
			velocity.y = GLIDE_TERMINAL_VELOCITY

		# Only play the sound effect when the player-character is moving downwards, not while
		# jumping upwards
		if velocity.y > 0 and not _glide_sfx.playing:
			_glide_sfx.play()
	elif _glide_sfx.playing:
		_glide_sfx.stop()


## If the "teleport" action is pressed, and the player is moving the character horizontally,
## teleport the character in that horizontal direction.
func _teleport(input_direction: float) -> void:
	if (
		Input.is_action_just_pressed(Actions.lookup(player, "teleport"))
		and not is_zero_approx(input_direction)
	):
		# TODO: Check if we are teleporting into a wall (in which case the player should lose a
		# life) or an enemy (in which case maybe the enemy should be telefragged/defeated?)
		global_position.x += TELEPORT_DISTANCE * input_direction
		_teleport_sfx.play()


## If the "phase" action is pressed, make the player-character invulnerable, but also unable to
## interact with coins.
func _phase() -> void:
	# Check if the player is holding the "phase" action button.
	if Input.is_action_just_pressed(Actions.lookup(player, "phase")):
		# While phasing, disable collisions on the PLAYER physics layer.
		set_collision_layer_value(Global.PhysicsLayers.PLAYER, false)
		set_collision_mask_value(Global.PhysicsLayers.PLAYER, false)

		# Make the sprite semitransparent
		_sprite.modulate.a = 0.5

		# TODO: Is this ability too powerful? Should it have a timer/stamina so the player can only
		# use it occasionally and for a short time?
	elif Input.is_action_just_released(Actions.lookup(player, "phase")):
		# Re-enable collisions on the PLAYER physics layer.
		set_collision_layer_value(Global.PhysicsLayers.PLAYER, true)
		set_collision_mask_value(Global.PhysicsLayers.PLAYER, true)

		# Make the sprite opaque again
		_sprite.modulate.a = 1


## When the "shrink" action is pressed, toggle the player between normal size and half-size. While
## shrunk, the player can pass through narrower passages, but cannot jump so high.
func _shrink() -> void:
	if Input.is_action_just_pressed(Actions.lookup(player, "shrink")):
		_is_shrunk = not _is_shrunk

		if _is_shrunk:
			# Shrink the player-character's sprite and collision shape
			scale = Vector2(0.5, 0.5)
		else:
			scale = Vector2(1, 1)

	if _is_shrunk:
		# Reduce the jump height while shrunk. _jump() sets velocity.y to -jump_velocity, so
		# clamping this to a smaller value cuts the initial upwards velocity, and hence the jump
		# height.
		if velocity.y < -jump_velocity * JUMP_VELOCITY_SCALE_WHEN_SMALL:
			velocity.y = -jump_velocity * JUMP_VELOCITY_SCALE_WHEN_SMALL

	# TODO: should there be other consequences to being small? Could we make the player somehow more
	# vulnerable to enemies?


func _physics_process(delta):
	# Don't move if there are no lives left.
	if Global.lives <= 0:
		return

	# _phase()

	# Handle jump
	if is_on_floor():
		coyote_timer = (coyote_time + delta)
		double_jump_armed = false

	if Input.is_action_just_pressed(Actions.lookup(player, "jump")):
		jump_buffer_timer = (jump_buffer + delta)

	if jump_buffer_timer > 0 and (double_jump_armed or coyote_timer > 0):
		_jump()

	# Reduce velocity if the player lets go of the jump key before the apex.
	# This allows controlling the height of the jump.
	if Input.is_action_just_released(Actions.lookup(player, "jump")) and velocity.y < 0:
		velocity.y *= (1 - (jump_cut_factor / 100.00))

	# Add the gravity.
	if coyote_timer <= 0:
		velocity.y += gravity * delta

	# _shrink()

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis(Actions.lookup(player, "left"), Actions.lookup(player, "right"))
	if direction:
		velocity.x = move_toward(
			velocity.x,
			sign(direction) * speed,
			abs(direction) * acceleration * delta,
		)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)

	# _glide()

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

	# _teleport(direction)

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
