extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str( get_index()+1 );
	pass # Replace with function body.

