extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("text_changed",setAnnonimousChannel)
	pass # Replace with function body.

func setAnnonimousChannelLabel(_event):
	print("setAnnonimousChannelLabel")
	text = $"../../../TwitchChatGodot".annonimousChannel
	

func setAnnonimousChannel(_event):
	$"../../../TwitchChatGodot".setAnnonimousChannel(text)
