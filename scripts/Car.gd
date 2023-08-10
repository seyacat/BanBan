extends RigidBody2D

var status
var vel
# Called when the node enters the scene tree for the first time.
func _ready():
	status = "new"
	vel = Vector2(0,0);
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if status != "game":
		return
	var acel = clamp( $JintMachine.getDouble('acel') , -GameData.settings.maxa, GameData.settings.maxa) 
	var aceladg = clamp( $JintMachine.getDouble('steer'),-GameData.settings.maxaa, GameData.settings.maxaa)  
	var acela =  aceladg * PI / 180 
	acel = acel if !is_nan(acel) else 0
	acela = acela if !is_nan(acela) else 0
	if !is_nan(acel) && !is_nan(acela):
		var veli = linear_velocity.length();
		var velf = (linear_velocity + (-global_transform.y) * acel).length()
		if abs(velf) < abs(veli) || abs(velf) < GameData.settings.maxv:
			linear_velocity = linear_velocity + (-global_transform.y) * acel
			linear_velocity = linear_velocity - linear_velocity.project(global_transform.x)
		var abs_vela = abs(angular_velocity + acela)
		if abs_vela < abs(angular_velocity) || abs(angular_velocity + acela) < GameData.settings.maxav:
			angular_velocity = angular_velocity + acela 
		
	pass
	
	
func _process_message_data(data):
	var msg = data.msg.right( data.msg.length()-1 ) 
	$CarSprite2D.modulate = Color.html(data.color) # blue shade
	$LabelContainer/Label.text = data.username
	$JintMachine.ExecMessage(msg)
