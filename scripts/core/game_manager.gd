# ゲーム進行の総合クラス
extends Node


# プレイ時間 (秒)
var uptime_sec: int = 0:
	get:
		var passed_sec = (Time.get_unix_time_from_system() - _wake_up_unixtime) * time_scale
		return _uptime_sec_stack + passed_sec
# プレイ時間 ("HHHH:MM:SS")
var uptime_string: String = "":
	get:
		var hours = floor(uptime_sec / 3600)
		var minutes = floor(uptime_sec / 60) % 60
		var seconds = uptime_sec % 60
		return "%04d:%02d:%02d" % [hours, minutes, seconds]
# プレイ速度倍率
var time_scale: int = 1:
	set(value):
		_uptime_sec_stack = uptime_sec
		_wake_up_unixtime = Time.get_unix_time_from_system()
		time_scale = clampi(value, 1, 1000)

var company_money: int = 1000 # 会社の資金


var _wake_up_unixtime: int = 0 # 起動開始時刻
var _uptime_sec_stack: int = 0 # プレイ速度倍率変更時用のこれまでのプレイ時間


func _ready() -> void:
	_wake_up_unixtime = Time.get_unix_time_from_system()
