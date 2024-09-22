class_name Core
extends Node


var uptime_sec = 0: # プレイ時間 (s)
	get:
		return  Time.get_unix_time_from_system() - _wake_up_time
var uptime_string = "": # プレイ時間 (HH:MM:SS)
	get:
		# TODO: 24h でオーバーフローする
		return Time.get_time_string_from_unix_time(uptime_sec)


var _wake_up_time = 0 # 起動開始時間 (Unixtime)


func _ready() -> void:
	_wake_up_time = Time.get_unix_time_from_system()


func _process(delta: float) -> void:
	pass
