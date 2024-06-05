extends Node

signal coin_collected
signal game_ended(ending: Endings)
signal gravity_changed(gravity: float)

enum Endings { WIN, LOSE }

## Stores the collected coins.
var coins: int = 0


func collect_coin():
	coins += 1
	coin_collected.emit()
