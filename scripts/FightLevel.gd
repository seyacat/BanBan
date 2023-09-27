extends Node2D
const playerBase = preload("res://Player.tscn")
const carBase = preload("res://Car.tscn")
var defaultSettingsData = GameData.settings;

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.state = "new";
	GameData.countdown = 10;
	GameData.finishOrder = [];
	GameData.nextLevel = "res://levels/Level2.tscn"
	
	RenderingServer.set_default_clear_color(Color(0.0,0.0,0.0,1.0))
	$TwitchChatGodot.connect("new_message",get_message)
	defaultSettingsData = GameData.settings;
	_load_settings()
	_update_ui_from_settings()
	
	$ClickOverlay.connect("new_message",get_click)
	

func _nextLevel():
	get_tree().change_scene_to_file(GameData.nextLevel)
	
			
func _reset_settings():
	GameData.settings = defaultSettingsData;
	_update_ui_from_settings();

func _update_ui_from_settings():
	$PanelSettings/VBoxContainer/HBoxContainer2/maxV.value = GameData.settings.maxv
	$PanelSettings/VBoxContainer/HBoxContainer3/maxA.value = GameData.settings.maxa
	$PanelSettings/VBoxContainer/HBoxContainer4/maxAV.value = GameData.settings.maxav
	$PanelSettings/VBoxContainer/HBoxContainer5/maxAA.value = GameData.settings.maxaa
	
func _update_settings_from_ui():
	GameData.settings.maxa = $PanelSettings/VBoxContainer/HBoxContainer3/maxA.value;
	GameData.settings.maxv = $PanelSettings/VBoxContainer/HBoxContainer2/maxV.value;
	GameData.settings.maxav = $PanelSettings/VBoxContainer/HBoxContainer4/maxAV.value;
	GameData.settings.maxaa = $PanelSettings/VBoxContainer/HBoxContainer5/maxAA.value;	

func get_click(data):
		var msg = {'cmd':'PRIVMSG','msg':''}
	msg['user-id'] = data.context['user_id'] if data.context.has('user_id') else data.context['opaque_user_id']
	if( data.has('user') && data.user.has('id') ):
		msg['username'] = data.user.login
		msg['display_name'] = data.user.display_name
	var playernode = get_node_or_null("Players/"+msg['user-id']);
	if !playernode:
		msg.msg = '!j'
		get_message(msg)
		return
	#mousedown,mouseup,click,touchstart,touchend
	if( data.data.type == 'mouseup' || data.data.type == 'touchend'):
		msg.msg= '!h'	
	if( data.data.type == 'click' && data.data.button == 0):
		msg.msg= '!m(%s,%s)' % [data.data.position.x,data.data.position.y]			
	if( data.data.type == 'click' && data.data.button == 2):
		var dx = data.data.position.x -playernode.position.x
		var dy = data.data.position.y -playernode.position.y
		msg.msg= '!_b = [%s,%s]' % [dx,dy]
	get_message(msg)
	
func get_message(data):
	_update_settings_from_ui()
	if data.has("cmd") && (data.cmd == "PRIVMSG" || data.cmd == "WHISPER"):
		#Join alternative
		data.msg = '!join' if data.msg=="!j" else data.msg

		
		var playernode = get_node_or_null("Players/"+data['user-id']);
		var current_life
		if !playernode && data.msg != "!join":
			return
		if playernode && data.msg == "!reset":
			current_life = playernode.life
			playernode.name = playernode.name + "_"
			$Players.remove_child(playernode)
			playernode.queue_free()
			playernode = null
			data.msg = "!join"
		
		#RESPAWN	
		if !playernode && data.msg == "!join":
			playernode = playerBase.instantiate()
			if current_life:
				playernode.life = current_life
			playernode.position = $Camera2D.position + Vector2( randf_range(-220,220), randf_range(-220,220) )
			playernode.name = data['user-id']
			$Players.add_child(playernode)
			data.msg = '!' #send empty to process message
		
		#Command Mapping
		data.msg = '!u()' if data.msg=="!u" else data.msg
		data.msg = '!d()' if data.msg=="!d" else data.msg
		data.msg = '!l()' if data.msg=="!l" else data.msg
		data.msg = '!r()' if data.msg=="!r" else data.msg
		data.msg = '!_h=true' if data.msg=="!h" else data.msg
		data.msg = '!' if data.msg=="!join" else data.msg
		
		GameData.updatePlayerData(data)
		
		if( data.has("msg") && data.msg.left(1) == '!' ):
			playernode._process_message_data(data)
			
func _save_settings():
	_update_settings_from_ui()
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_var(GameData.settings)	
	
	
func _load_settings():
	if FileAccess.file_exists("user://settings.dat"):
		var file = FileAccess.open("user://settings.dat", FileAccess.READ)
		GameData.settings = file.get_var()
		_update_ui_from_settings()
		
