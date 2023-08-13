extends CharacterBody2D

var settings = {}
var vel
# Called when the node enters the scene tree for the first time.
func _ready():
	vel = Vector2(0,0);
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var acelArray = $JintMachine.getDoubleArray('acel')
	if acelArray.size() == 2:
		$AnimatedSprite2D.flip_h = acelArray[0] < 0
		var acel = Vector2(acelArray[0],acelArray[1])
		var amagnitude = acel.length();
		if( amagnitude > GameData.maxa/100.0 ):
			var anormal = acel.normalized();
			acel = anormal * GameData.maxa/100.0;
		vel = vel + acel
		var vmagnitude = vel.length()
		if( vmagnitude > GameData.maxv/100.0 ):
			var vnormal = acel.normalized();
			vel = vnormal * GameData.maxv/100.0;
		move_and_collide(vel)
		
	pass
	
	
func _process_message(msg):
	$JintMachine.ExecMessage(msg)

