class_name Coin
extends Area2D


func _on_body_entered(_body):
	Global.collect_coin()
	queue_free()
