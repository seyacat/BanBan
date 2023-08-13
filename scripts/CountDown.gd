extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	#ONE SECOND TIMER
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	
	visible = false

func _tic():
	if GameData.countdown > 0 :
		visible = true
		GameData.countdown -= 1
		$Label.text = str( GameData.countdown );
	else:
		visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.

	
