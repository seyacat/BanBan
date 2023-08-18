extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.connect("animation_finished",destroy)
	pass # Replace with function body.

func destroy(_event):
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
