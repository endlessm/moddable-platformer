extends Node


signal coin_collected
signal gravity_changed(gravity: float)


## Stores the collected coins.
var coins: int = 0


func collect_coin():
	coins += 1
	coin_collected.emit()
