extends CharacterBody2D
const bomb = preload("res://props/bomb.tscn")
var settings = {}
var vel
# Called when the node enters the scene tree for the first time.
func _ready():
	vel = Vector2(0,0);
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var vel = $JintMachine.getDoubleArray('v')
	if vel.size() == 2:
		move_and_collide(Vector2( vel[0],vel[1]).clamp( Vector2(-1,-1),Vector2(1,1)))
	"""var bvel = $JintMachine.getDoubleArray('b_target')
	if bvel.size() == 2:
		var b = bomb.instantiate();
		b.linear_velocity( Vector2( bvel[0],bvel[1]).clamp( Vector2(-1,-1),Vector2(1,1)) )
		get_parent().add_child(b)
		#move_and_collide(Vector2( vel[0],vel[1]).clamp( Vector2(-1,-1),Vector2(1,1)))"""
	
		
	pass
	
	
func _process_message_data(data):
	var msg = data.msg.right( data.msg.length()-1 ) 
	#$CarSprite2D.modulate = Color.html(data.color) # blue shade
	$LabelContainer/Label.text = data.username
	$JintMachine.ExecMessage(msg)

