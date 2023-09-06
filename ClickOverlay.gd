extends Node

# oauth-dev.seyacat.com client_id integration
var ws = WebSocketPeer.new() 
var is_connected = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	_ws_connect()

func _tic(): 
	pass
			

func _ws_connect():
	set_process(true)
	var err = ws.connect_to_url("wss://backend.seyacat.com:8082");
	print("connectiong wss://backend.seyacat.com:8082")
	if err != 0:
		print("Unable to connect")
		set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	is_connected = true;
	
	ws.send_text("{\"channel_id\":\"194927077\"}")
	
func _on_data(msg):
	
	print(msg)
	#Regex regex = new Regex(@"(.*?):(?:(([a-zA-Z0-9_]*?)!([a-zA-Z0-9_]*?)@[a-zA-Z0-9_]*?.tmi.twitch.tv)|tmi.twitch.tv)\s([A-Z]*?)?\s#([^\s]*)\s{0,}:?(.*?)?$", RegexOptions.IgnoreCase);
	
func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	_ws_connect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	ws.poll()
	var state = ws.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if !is_connected:
			print(state == WebSocketPeer.STATE_OPEN)
			is_connected = true
			_connected()
		while ws.get_available_packet_count():
			_on_data( ws.get_packet().get_string_from_utf8() )
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		is_connected = false
		var code = ws.get_close_code()
		var reason = ws.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
		

	
	


