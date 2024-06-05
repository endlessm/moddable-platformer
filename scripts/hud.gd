extends CanvasLayer

@onready var ending_labels = {
	Global.Endings.WIN: %WinEnding,
	Global.Endings.LOSE: %LoseEnding,
}


func _ready():
	Global.coin_collected.connect(_on_coin_collected)
	Global.game_ended.connect(_on_game_ended)


func _unhandled_input(event):
	if event is InputEventKey and %Start.is_visible_in_tree():
		%Start.hide()


func _on_coin_collected():
	set_collected_coins(Global.coins)


func set_collected_coins(coins: int):
	%CollectedCoins.text = "Coins: " + str(coins)


func _on_game_ended(ending: Global.Endings):
	ending_labels[ending].visible = true
