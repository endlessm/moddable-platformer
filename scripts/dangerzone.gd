@tool
extends Area2D

signal dangerzone_entered

@export var shape: Shape2D:
	set(value):
		if not is_node_ready():
			await ready
		%CollisionShape2D.shape = value
	get:
		return %CollisionShape2D.shape


func _on_body_entered(_body):
	Global.game_ended.emit(Global.Endings.LOSE)
	dangerzone_entered.emit()
