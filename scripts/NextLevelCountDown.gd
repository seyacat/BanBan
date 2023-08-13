extends Node2D

signal finish

func _ready():
	visible = false

func _process(delta):
	if GameData.nextLevelCountdown > 0:
		visible = true
		GameData.nextLevelCountdown = GameData.nextLevelCountdown - delta
		$Panel/Label2.text = str(  snapped( GameData.nextLevelCountdown , 0.01) )  + " s"
		if( GameData.nextLevelCountdown <=0 ):
			emit_signal("finish")
	else:
		visible = false
	pass
