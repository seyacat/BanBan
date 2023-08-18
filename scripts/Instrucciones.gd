extends Panel

var index = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(10.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	

func _tic():
	var c = 0;
	for child in get_children():
		if not child is Label:
			continue
		if c == index:
			child.visible = true
		else:
			child.visible = false
		c += 1
	index = (index+1) % (get_child_count()-1)
	
