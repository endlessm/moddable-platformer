class_name GameLogic
extends Node

@export_group("Win Condition")

## Should you win the game by collecting coins?
@export var win_by_collecting_coins: bool = false

# HACK: the step needs to be 0.9 for displaying a slider.
## How many coins to collect for winning?
## If zero, all the coins must be collected.[br]
## [b]Note:[/b] if you set this to a number bigger than the actual coins,
## the game won't be winnable.
@export_range(0, 100, 0.9, "or_greater") var coins_to_win: int = 0

@export_group("Challenges")
## You lose if this time runs out.
## If zero (default), there won't be a time limit to win.
@export_range(0, 60, 0.9, "or_greater") var time_limit: int = 0

## How many lives does the player have?
@export_range(1, 9) var lives: int = 3

@export_group("World Properties")

# Keep default the same as ProjectSettings.get_setting("physics/2d/default_gravity")
## This is the gravity of the world. In pixels per second squared.
@export_range(-2000.0, 2000.0, 0.1, "suffix:px/s²") var gravity: float = 980.0


func _get_all_coins(node, accumulator = []):
	if node is Coin:
		accumulator.append(node)
	for child in node.get_children():
		_get_all_coins(child, accumulator)


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	# Set the gravity strength at runtime:
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity
	)
	Global.gravity_changed.emit(gravity)
	if win_by_collecting_coins:
		Global.coin_collected.connect(_on_coin_collected)
		if coins_to_win == 0:
			var coins = []
			_get_all_coins(get_parent(), coins)
			coins_to_win = coins.size()
	Global.lives = lives

	if time_limit > 0:
		Global.setup_timer(time_limit)


func _on_coin_collected():
	if win_by_collecting_coins and Global.coins >= coins_to_win:
		Global.game_ended.emit(Global.Endings.WIN)
