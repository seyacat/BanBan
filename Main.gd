extends Node2D
const playerBase = preload("res://Player.tscn")
const carBase = preload("res://Car.tscn")
var defaultSettingsData = Settings.data;
# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color(0.0,0.0,0.0,1.0))
	$TwitchChatGodot.connect("new_message",get_message)
	defaultSettingsData = Settings.data;
	_load_settings()
	_update_ui_from_settings()

func _reset_settings():
	Settings.data = defaultSettingsData;
	_update_ui_from_settings();

func _update_ui_from_settings():
	$Panel/VBoxContainer/HBoxContainer2/maxV.value = Settings.data.maxv
	$Panel/VBoxContainer/HBoxContainer3/maxA.value = Settings.data.maxa
	$Panel/VBoxContainer/HBoxContainer4/maxAV.value = Settings.data.maxav
	$Panel/VBoxContainer/HBoxContainer5/maxAA.value = Settings.data.maxaa
	
func _update_settings_from_ui():
	Settings.data.maxa = $Panel/VBoxContainer/HBoxContainer3/maxA.value;
	Settings.data.maxv = $Panel/VBoxContainer/HBoxContainer2/maxV.value;
	Settings.data.maxav = $Panel/VBoxContainer/HBoxContainer4/maxAV.value;
	Settings.data.maxaa = $Panel/VBoxContainer/HBoxContainer5/maxAA.value;	

func get_message(data):
	_update_settings_from_ui()
	if data.has("cmd") && data.cmd == "PRIVMSG":
		var playernode = get_node_or_null("Players/"+data['user-id']);
		print(playernode)
		print(data['user-id'])
		if !playernode:
			#playernode = playerBase.instantiate()
			playernode = carBase.instantiate()
			playernode.name = data['user-id']
			$Players.add_child(playernode)
			playernode.position = Vector2(-400+20*($Players.get_child_count()% 80) , 200);
		if( data.has("msg") ):
			if( data.msg.left(1) == '!'  ):
				playernode._process_message_data(data)
			
func _save_settings():
	_update_settings_from_ui()
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_var(Settings.data)	
	
	
func _load_settings():
	if FileAccess.file_exists("user://settings.dat"):
		var file = FileAccess.open("user://settings.dat", FileAccess.READ)
		Settings.data = file.get_var()
		_update_ui_from_settings()
		
