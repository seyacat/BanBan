extends Area2D

var timeout = 1
var player_id
# Called when the node enters the scene tree for the first time.
func _ready():
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	pass # Replace with function body.
	pass # Replace with function body.

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if(body.has_method('damage')):
			body.damage(delta*50,player_id)

func _tic():
	timeout -= 1
	if(timeout <= 0):
		queue_free()
