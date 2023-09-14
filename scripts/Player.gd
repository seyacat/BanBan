extends CharacterBody2D
const bomb = preload("res://props/bomb.tscn")
const diePlayer = preload("res://DiePlayer.tscn")
var settings = {}
var cooldown = 50
var life = 100
var animation_state = 'idle'
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.connect("animation_finished",_animation_finished)
	pass # Replace with function body.

func _animation_finished(anim):
	animation_state = 'idle'
	if(anim == 'attack'):
		$Area2D/CollisionShape2D.disabled = true;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if(body.has_method('damage') && body != self):
			body.damage(delta*50,name)
	
	life =  clamp( life + delta , 0 , 100)
	cooldown =  clamp( cooldown + 20*delta , 0 , 100)
	$LabelContainer/Life.value = life
	$LabelContainer/Cooldown.value = cooldown
	var vel = $JintMachine.getDoubleArray('_v')
	if vel.size() == 2 && !is_nan(vel[0]) && !is_nan(vel[1]):
		var last_position = position
		if( vel[0] != 0 ):
			$Sprite2D.flip_h = vel[0]<0;
		move_and_collide(Vector2( vel[0],vel[1]).clamp( Vector2(-1,-1),Vector2(1,1)))
		
		if(last_position != position):
			animation_state = 'walk'
	var bvel = $JintMachine.getDoubleArrayAndNulify('_b')
	if bvel.size() == 2 && cooldown >= 100:
		cooldown = 0
		var max_bvel = 200;
		var b = bomb.instantiate();
		b.player_id = name
		b.add_collision_exception_with(self)
		b.position = position
		get_node("../../Bombs").add_child(b)
		b.linear_velocity = Vector2( bvel[0],bvel[1]).clamp( Vector2(-max_bvel,-max_bvel),Vector2(max_bvel,max_bvel)) 
	
	var _d = $JintMachine.getDoubleAndNulify('_d')	
	if !is_nan(_d) && life > 10 :
		life -= _d/200
		
	var _h = $JintMachine.getBooleanAndFalse('_h')	
	if _h && cooldown >=100 :
		cooldown = 50;
		$Area2D/CollisionShape2D.disabled = false;
		animation_state = 'attack'
		
		#move_and_collide(Vector2( vel[0],vel[1]).clamp( Vector2(-1,-1),Vector2(1,1)))"""
	if($AnimationPlayer.current_animation != animation_state):
		$AnimationPlayer.play(animation_state)

	if(life <= 0):
		kill()
	
func damage(d,player_id):
	GameData.addPoints(player_id,ceil(d));
	animation_state = 'damage'
	life -= d;
	
		
func kill():
	#get_tree().root()$TwitchChatGodot._ban(  )
	get_node("../../TwitchChatGodot")._ban(GameData.players[name],5,"MUERTO")
	var dp = diePlayer.instantiate()
	dp.position = position
	dp.get_node("Sprite2D").flip_h = $Sprite2D.flip_h
	get_parent().add_child(dp)
	queue_free()
	
	
func _process_message_data(data):
	var msg = data.msg.right( data.msg.length()-1 ) 
	#$CarSprite2D.modulate = Color.html(data.color) # blue shade
	if(data.has('username')):
		$LabelContainer/Label.text = data.username
	$JintMachine.ExecMessage(msg)

