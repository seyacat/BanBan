extends RigidBody2D

const explotion = preload("res://props/explotion.tscn")
var player_id

var timeout = 10;
# Called when the node enters the scene tree for the first time.
func _ready():
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	pass # Replace with function body.

func _tic():
	timeout -= 1
	$LabelContainer/Label.text = str(timeout)
	if timeout <= 0:
		$CollisionShape2D.disabled = true
		var expl = explotion.instantiate()
		expl.player_id = player_id
		expl.position = position
		get_parent().add_child(expl);
		
		queue_free()
		
