extends Node

var token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InNleWFjYXRAZ21haWwuY29tIiwiaXAiOiIxODEuMTk5LjU5Ljc2Iiwic2NvcGUiOm51bGwsImlhdCI6MTY4OTIxNjU4MiwiZXhwIjoxNjg5MjE4MzgyLCJhdWQiOiJhY2Nlc3MifQ.PWVKwwCj1T1sY3gVaZDZ6HRVFNfPmTbwxYyVvBJNUZm3SNEPU8mMZyKOhjz4aYHTyfnhcy4rLEhBljdkWqvoRcNkUYC3aZKK1fd8qBP_54e0LCAx8kXK1Xbfn370PSvBWDDb_qYAM2UtoapeTOqi_9bMoDg2kstfs7ZlELvtw28XVRSCOkuZY0qomscjbuR9VHz8T7QDW71eeKNancGOXUA-bawbW42IAkx_6QcywkWtcJbk2WPJhaYFyuaLF4X1Lxw5-MqRfjDhqxSIAcCjNK4zPmgWiE57oCVyJiCN8IZYbVlvGh-YivogrrxiTzhnVxsh8viJk-4lSnecFWqyVg&refresh_token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InNleWFjYXRAZ21haWwuY29tIiwiaWF0IjoxNjg5MjE2NTgyLCJleHAiOjE2ODkzODkzODIsImF1ZCI6InJlZnJlc2gifQ.h-IK9x7jk-eDA_g7zHWdX7hm1UHPr1Qdi7nnLx1gVnLYzR7zq6LWI6-D6OSo7sEXoZjcK4Rbpb421AhnWrbtwlpTk2MB_sXbajjwdJqwzHMJB7v-yBcEzIwFyTxMulilBdWPGXktUfQ08U4aypafUPv4OKSJscyXl6JYzSRPWb_oV-WNy-Qqpo-xiKkwjQ6uhM6tatITQ0MlwycQJ_EeKxt8Xt-0RaYKbCckb1xXeLhvYctJOHikAdHIdtllggPXmJyT7AW9wdCO4xP8rF-NZ5MS7uEUV5jQd_wBnk6gaC8vrM7vbWhxgbQhA7a3gjjX9P-GBqaf4PvkbvTxirEakQ"
var socket = WebSocketPeer.new()
var fc = false

func _ready():
	socket.connect_to_url("wss://irc-ws.chat.twitch.tv:443")

func _process(delta):
	
	socket.poll()
	var state = socket.get_ready_state()
	print(state)
	if state == WebSocketPeer.STATE_OPEN:
		
		if !fc:
			fc = true
			#socket.put_packet("CAP REQ :twitch.tv/membership twitch.tv/tags twitch.tv/commands".to_wchar_buffer());
			#socket.put_packet(("PASS oauth:"+ token ).to_ascii_buffer());
			#socket.put_packet("NICK pamela104".to_ascii_buffer());
			#socket.put_packet("JOIN #seyacat".to_ascii_buffer());

		while socket.get_available_packet_count():
			print("Packet: ", socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

