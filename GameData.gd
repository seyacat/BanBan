extends Node

var state
var countdown = 0
var nextLevel
var nextLevelCountdown = 0
var finishOrder
var players={}

var settings={
 "mass" = 1, #MASA
 "maxv" = 100, #VELOCIDAD
 "maxa" = 100, #ACELERACION
 "maxav" = 100, #VELOCIDAD ANGULAR
 "maxaa" = 100, #ACELERACION ANGULAR
}


func updatePlayerData(data):
	if (data.cmd == 'PRIVMSG' || data.cmd == 'WHISPER' ) && !players.has(data["user-id"]):
		players[data["user-id"]] = {}
	for i in data:
		players[data["user-id"]][i] = data[i];
	if !players[data["user-id"]].has("points"):
		players[data["user-id"]].points = 0;
	if !players[data["user-id"]].has("localpoints"):
		players[data["user-id"]].localpoints = 0;
		
func getTop10():
	var playersArray = []
	var topPlayers = []
	for p in players:
		playersArray.push_back(players[p])
	playersArray.sort_custom(points_array_sort)
	for p in playersArray:
		topPlayers.push_back(p)
	return topPlayers
	
func addPoints(player_id,p):
	players[player_id].localpoints = p
	players[player_id].points += p
	
func points_array_sort(a, b):
	return a.points > b.points
	
	
