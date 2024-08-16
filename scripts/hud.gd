@tool
extends CanvasLayer

@onready var ending_labels = {
	Global.Endings.WIN: %WinEnding,
	Global.Endings.LOSE: %LoseEnding,
}


func _process(_delta):
	%TimeLeft.text = "%.1f" % Global.timer.time_left


func _ready():
	set_process(false)
	set_physics_process(false)

	Global.lives_changed.connect(_on_lives_changed)

	if Engine.is_editor_hint():
		return

	Global.coin_collected.connect(_on_coin_collected)
	Global.game_ended.connect(_on_game_ended)
	Global.timer_added.connect(_on_timer_added)


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


func _on_lives_changed():
	set_lives(Global.lives)


func set_lives(lives: int):
	%Lives.offset_right = %Lives.offset_left + lives * %Lives.texture.get_width()


func _on_game_ended(ending: Global.Endings):
	ending_labels[ending].visible = true
