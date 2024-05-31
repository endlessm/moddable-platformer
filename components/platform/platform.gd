@tool
class_name Platform
extends Node2D

enum PlatformType { FULL, SKINNY }

const TILE_WIDTH: int = 64
const SPRITE: Texture2D = preload("res://assets/world_tiles_1.png")

@export var type: PlatformType = PlatformType.FULL:
	set = _set_type

@export_range(1, 20, 1) var width: int = 3:
	set = _set_width

@export var one_way: bool = false

## Number of seconds after touching platform to fall. Negative values won't fall
@export var fall_time: float = -1

var fall_timer: Timer
var _shaking := false

@onready var _rigid_body := %RigidBody2D
@onready var _sprites := %Sprites
@onready var _collision_shape := %CollisionShape2D
@onready var _area_collision_shape := %AreaCollisionShape2D


func _set_type(new_type):
	type = new_type

	if is_node_ready():
		_recreate_sprites()


func _set_width(new_width):
	width = new_width

	if is_node_ready():
		_recreate_sprites()


func _recreate_sprites():
	for c in _sprites.get_children():
		c.queue_free()

	_collision_shape.shape = RectangleShape2D.new()
	_collision_shape.one_way_collision = one_way

	match type:
		PlatformType.FULL:
			_collision_shape.shape.set_size(Vector2(width * TILE_WIDTH, TILE_WIDTH))
			_collision_shape.position.y = 0
		PlatformType.SKINNY:
			_collision_shape.shape.set_size(Vector2(width * TILE_WIDTH, 40))
			_collision_shape.position.y = -12

	_area_collision_shape.shape = _collision_shape.shape
	_area_collision_shape.position = _collision_shape.position + Vector2(0, -8)

	var center: float = (width - 1) * TILE_WIDTH / 2.0

	for i in range(0, width):
		var new_sprite := Sprite2D.new()
		new_sprite.texture = SPRITE
		new_sprite.hframes = 10
		new_sprite.vframes = 4
		new_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		match type:
			PlatformType.FULL:
				new_sprite.frame_coords = Vector2i(0, 1)
			PlatformType.SKINNY:
				new_sprite.frame_coords = Vector2i(1, 1)

		new_sprite.position = Vector2(i * TILE_WIDTH - center, 0)
		_sprites.add_child(new_sprite)


func _ready():
	_recreate_sprites()

	fall_timer = Timer.new()
	fall_timer.one_shot = true
	fall_timer.timeout.connect(_fall)
	add_child(fall_timer)


func _physics_process(_delta):
	if _shaking:
		_sprites.position = 2 * Vector2(randf(), randf())


func _on_area_2d_body_entered(body):
	# TODO: Add Player class_name to player.gd
	if body.name == "Player":
		# HACK: When player enters trigger area from top
		if abs(body.position.y - position.y + 64) < 5:
			if fall_time > 0:
				fall_timer.start(fall_time)
				_shaking = true
			if fall_time == 0:
				_rigid_body.call_deferred("set_freeze_enabled", false)


func _fall():
	_rigid_body.freeze = false
	_shaking = false
