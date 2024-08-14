extends Node

signal coin_collected
signal game_ended(ending: Endings)
signal gravity_changed(gravity: float)
signal timer_added

enum Endings { WIN, LOSE }

## Timer for finishing the level.
var timer: Timer

## Stores the collected coins.
var coins: int = 0


func collect_coin():
	coins += 1
	coin_collected.emit()


func setup_timer(time_limit: int):
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start(time_limit)
	timer_added.emit()


func _on_timer_timeout():
	game_ended.emit(Endings.LOSE)
