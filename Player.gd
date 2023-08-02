extends Node2D

var settings = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += clamp(  $JintMachine.dx , -Settings.maxdx , Settings.maxdx );
	position.y += clamp(  $JintMachine.dy , -Settings.maxdy , Settings.maxdy )

	pass
	
func _process_message(msg):
	$JintMachine.ExecMessage(msg)

