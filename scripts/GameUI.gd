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
	pass # Replace with function body.

func _tic():
	removeAllChildren($Panel/VBoxContainer/Top10)
	removeAllChildren($Panel/VBoxContainer/finishOrder)
	for p in GameData.finishOrder:
		var label = Label.new();
		label.size_flags_horizontal = 2
		var labelPoints = Label.new();
		var player = GameData.players[p]
		labelPoints.text = str(player.localpoints)
		label.text = player["display-name"] ;
		$Panel/VBoxContainer/finishOrder.add_child( label )
		$Panel/VBoxContainer/finishOrder.add_child( labelPoints )
	for p in GameData.getTop10():
		var label = Label.new();
		label.size_flags_horizontal = 2
		var labelPoints = Label.new();
		label.text = p["display-name"];
		labelPoints.text = str(p.points)
		$Panel/VBoxContainer/Top10.add_child( label )
		$Panel/VBoxContainer/Top10.add_child( labelPoints )

func removeAllChildren(node):
	for c in node.get_children():
		node.remove_child(c)
