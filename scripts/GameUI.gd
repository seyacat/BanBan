extends Node2D

var topContainer
# Called when the node enters the scene tree for the first time.
func _ready():
	topContainer = $Panel/VBoxContainer/Top10
	#ONE SECOND TIMER
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	pass # Replace with function body.

func _tic():
	removeAllChildren(topContainer)
	for p in GameData.getTop10():
		var label = Label.new();
		label.size_flags_horizontal = 2
		var labelPoints = Label.new();
		
		label.text = p["display-name"] if p.has("display-name") else 'Anonimo';
			
		labelPoints.text = str(p.points)
		topContainer.add_child( label )
		topContainer.add_child( labelPoints )

func removeAllChildren(node):
	if !node:
		return
	for c in node.get_children():
		node.remove_child(c)
