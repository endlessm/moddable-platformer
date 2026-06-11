extends Node

@onready var _canvas_layer: CanvasLayer = %CanvasLayer
@onready var _tree := get_tree()
@onready var _resume_button: Button = %Resume
@onready var _restart_button: Button = %Restart
@onready var _quit_button: Button = %Quit


func _ready() -> void:
	_resume_button.pressed.connect(resume)
	_restart_button.pressed.connect(restart)

	_quit_button.visible = OS.get_name() != "Web"
	_quit_button.pressed.connect(_tree.quit)

	_canvas_layer.visible = false


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return

	get_viewport().set_input_as_handled()
	if _tree.paused:
		resume()
	else:
		pause()


func pause() -> void:
	_canvas_layer.visible = true
	_tree.paused = true
	_resume_button.grab_focus()


func resume() -> void:
	_tree.paused = false
	_canvas_layer.visible = false


func restart() -> void:
	resume()
	_tree.reload_current_scene()
