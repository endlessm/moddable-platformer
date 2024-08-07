extends CanvasLayer

@onready var ending_labels = {
	Global.Endings.WIN: %WinEnding,
	Global.Endings.LOSE: %LoseEnding,
}


func _process(_delta):
	%TimeLeft.text = "%.1f" % Global.timer.time_left


func _ready():
	Global.coin_collected.connect(_on_coin_collected)
	Global.game_ended.connect(_on_game_ended)
	Global.timer_added.connect(_on_timer_added)
	set_process(false)
	set_physics_process(false)


func _unhandled_input(event):
	if event is InputEventKey and %Start.is_visible_in_tree():
		%Start.hide()


func _on_coin_collected():
	set_collected_coins(Global.coins)


func set_collected_coins(coins: int):
	%CollectedCoins.text = "Coins: " + str(coins)


func _on_timer_added():
	%TimeLeft.visible = true
	set_process(true)


func _on_game_ended(ending: Global.Endings):
	ending_labels[ending].visible = true
