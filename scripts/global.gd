@tool
extends Node

signal coin_collected
signal flag_raised(flag: Flag)
signal lives_changed
signal game_ended(ending: Endings)
signal gravity_changed(gravity: float)
signal timer_added

enum Endings { WIN, LOSE }
enum Player { ONE, TWO, BOTH }

## Timer for finishing the level.
var timer: Timer

## Stores the collected coins.
var coins: int = 0

## Stores the number of remaining lives.
var lives: int = 0:
	set = _set_lives


func collect_coin():
	coins += 1
	coin_collected.emit()


func raise_flag(flag: Flag):
	flag_raised.emit(flag)


func setup_timer(time_limit: int):
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start(time_limit)
	timer_added.emit()


func _on_timer_timeout():
	game_ended.emit(Endings.LOSE)


func _set_lives(value):
	if value < 0:
		return
	lives = value
	lives_changed.emit()
	if lives <= 0:
		game_ended.emit(Global.Endings.LOSE)
