class_name Core
extends Node


# プレイ時間 (s)
var uptime_sec: int = 0:
	get:
		return (Time.get_unix_time_from_system() - _wake_up_unixtime) * time_scale
# プレイ時間 (HH:MM:SS)
var uptime_string: String = "":
	get:
		# TODO: 24h でオーバーフローする
		return Time.get_time_string_from_unix_time(uptime_sec)
# プレイ速度倍率
var time_scale: int = 1:
	set(value):
		time_scale = clamp(value, 1, 1000)


var _wake_up_unixtime = 0 # 起動開始時刻


func _ready() -> void:
	_wake_up_unixtime = Time.get_unix_time_from_system()


func _process(delta: float) -> void:
	pass
