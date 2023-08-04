extends Node2D
const playerBase = preload("res://Player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color(0.0,0.0,0.0,1.0))
	$TwitchChatGodot.connect("new_message",get_message)

func _update_settings():
	Settings.maxa = $Panel/VBoxContainer/HBoxContainer3/maxA.value;
	Settings.maxv = $Panel/VBoxContainer/HBoxContainer2/maxV.value;	

func get_message(data):
	_update_settings()
	if data.has("cmd") && data.cmd == "PRIVMSG":
		var playernode = get_node_or_null("Players/"+data['user-id']);
		print(playernode)
		print(data['user-id'])
		if !playernode:
			playernode = playerBase.instantiate()
			playernode.name = data['user-id']
			$Players.add_child(playernode)
		if( data.has("msg") ):
			if( data.msg.left(1) == '!'  ):
				var msg = data.msg.right( data.msg.length()-1 ) 
				playernode._process_message(msg)
			
