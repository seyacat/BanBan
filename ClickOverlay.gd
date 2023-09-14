extends Node

# oauth-dev.seyacat.com client_id integration
var ws = WebSocketPeer.new() 
var is_connected = false;
var calibrationNode1
var calibrationNode2
var testNode
var dialog
var calibrateButton
var calibrateStatus
var first_point = Vector2(110.3667, 796.6901)
var second_point = Vector2(626.0456, 304.2253)
signal new_message(data);
# Called when the node enters the scene tree for the first time.
func _ready():
	var _timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", _tic)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	_ws_connect()
	calibrationNode1 = $P1;
	calibrationNode2 = $P2;
	testNode = $P3
	dialog = $Dialog;
	calibrateButton = $CalibrateButton;
	calibrateButton.get_node("Area2D").connect('input_event',onArea2Dinputevent)
	calibrationNode1.visible = false
	calibrationNode2.visible = false
	dialog.visible = false;

func onArea2Dinputevent( _viewport, event, _shapeidx ):
	if (event is InputEventMouseButton && event.pressed):
		calibrateStatus = "first_point"
		calibrationNode1.visible = true
		calibrationNode2.visible = false
		dialog.visible = true;

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
	if(typeof(msg) != TYPE_STRING):
		return	
	var data = JSON.parse_string(msg);	
	if !data:
		return
	var pos = Vector2(data.data.position[0],data.data.position[1])

	if(calibrateStatus=="first_point" && data.data.type == 'click' && data.context.role == 'broadcaster'):
		first_point = pos;
		calibrateStatus="second_point"
		calibrationNode1.visible = false
		calibrationNode2.visible = true
		return
	elif calibrateStatus=="second_point" && data.data.type == 'click' && data.context.role == 'broadcaster':
		calibrateStatus=null
		second_point = pos;
		calibrationNode1.visible = false
		calibrationNode2.visible = false
		dialog.visible = false
		return
	
	if( !first_point || !second_point || calibrateStatus != null ):
		return
		
	data.data.position = calculateCalibrationMatrix(calibrationNode1.position,
		calibrationNode2.position,first_point,second_point,pos)
		
	testNode.position = data.data.position
		
	emit_signal("new_message",data)


func calculateCalibrationMatrix(p1,p2,q1,q2,t1):
	var translateMatrix = Transform2D()
	translateMatrix = translateMatrix.translated(p1) 
	
	var scaleMatrix = Transform2D()
	scaleMatrix = scaleMatrix.scaled( Vector2( (p2.x-p1.x)/(q2.x-q1.x),(p2.y-p1.y)/(q2.y-q1.y) ) )
	
	var offsetMatrix = Transform2D()
	offsetMatrix = offsetMatrix.translated(q1-p1)
	
	return t1 * offsetMatrix *  translateMatrix * scaleMatrix * translateMatrix.inverse()
	
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
		
