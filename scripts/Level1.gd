extends Node2D
const playerBase = preload("res://Player.tscn")
const carBase = preload("res://Car.tscn")
var defaultSettingsData = GameData.settings;

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.state = "new";
	GameData.countdown = 10;
	
	#ONE SECOND TIMER
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	
	RenderingServer.set_default_clear_color(Color(0.0,0.0,0.0,1.0))
	$TwitchChatGodot.connect("new_message",get_message)
	defaultSettingsData = GameData.settings;
	_load_settings()
	_update_ui_from_settings()
	
func _physics_process(delta):
	for body in $Respawn/Area2D.get_overlapping_bodies():
		body.status = GameData.state;
	for body in $Finish/Area2D.get_overlapping_bodies():
		print(body)
		body.status = "finish";
	

func _tic():
	if GameData.state == "new":
		GameData.countdown -= 1
		if GameData.countdown <= 0:
			GameData.state = "game"
	
			
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

func get_message(data):
	_update_settings_from_ui()
	if data.has("cmd") && data.cmd == "PRIVMSG":
		var playernode = get_node_or_null("Players/"+data['user-id']);
		print(playernode)
		print(data['user-id'])
		if !playernode && data.msg != "!join":
			return
		if !playernode && data.msg == "!join":
			#playernode = playerBase.instantiate()
			playernode = carBase.instantiate()
			playernode.name = data['user-id']
			$Players.add_child(playernode)
			playernode.position = $Respawn.position + Vector2(30*($Players.get_child_count() % 20),20);
			data.msg = '!' #send empty to process message
		
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
		
