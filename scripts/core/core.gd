# ゲーム進行の総合クラス
# 必要に応じて切り出す
class_name Core
extends Node


# プレイ時間 (秒)
var uptime_sec: int = 0:
	get:
		return _uptime_sec_stack + (Time.get_unix_time_from_system() - _wake_up_unixtime) * time_scale
# プレイ時間 (HH:MM:SS)
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
		time_scale = clampi(value, 1, 10000)

var company_money: int = 1000 # 会社の資金

var employees: Array[CoreEmployeeBase] = [] # 雇用している従業員
var material_amounts: Dictionary = {} # 所持している素材 { CoreMaterial.Type: <amount> }
var unlocked_material_types: Array[CoreMaterial.Type] = [] # アンロックされている素材


var _wake_up_unixtime: int = 0 # 起動開始時刻
var _uptime_sec_stack: int = 0 # プレイ速度倍率変更時用のこれまでのプレイ時間


func _ready() -> void:
	_wake_up_unixtime = Time.get_unix_time_from_system()

	# 初期アンロック素材
	unlock_material(CoreMaterial.Type.D2_1)
	unlock_material(CoreMaterial.Type.D3_1)
	unlock_material(CoreMaterial.Type.PROGRAM_1)
	unlock_material(CoreMaterial.Type.RPG_1)


func get_material_amount(type: CoreMaterial.Type) -> int:
	if material_amounts.keys().has(type):
		return material_amounts[type]
	else:
		return 0

func unlock_material(type: CoreMaterial.Type) -> void:
	if unlocked_material_types.has(type):
		return
	unlocked_material_types.append(type)
	material_amounts[type] = 0


func add_employee(employee: CoreEmployeeBase) -> void:
	employee.init_core(self)
	employees.append(employee)
	add_child(employee)
