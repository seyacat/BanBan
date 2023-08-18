extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(5.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()

	RenderingServer.set_default_clear_color(Color.BLACK)
	pass # Replace with function body.

func _tic():
	get_tree().change_scene_to_file("res://levels/FightLevel.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _start_game():
	get_tree().change_scene_to_file("res://levels/FightLevel.tscn")
