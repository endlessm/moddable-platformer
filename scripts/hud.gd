extends CanvasLayer


func _ready():
	Global.coin_collected.connect(_on_coin_collected)


func _unhandled_input(event):
	if event is InputEventKey and %Start.is_visible_in_tree():
		%Start.hide()


func _on_coin_collected():
	set_collected_coins(Global.coins)


func set_collected_coins(coins: int):
	%CollectedCoins.text = "Coins: " + str(coins)
