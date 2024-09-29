# ゲーム上の従業員を管理するクラス
extends Node


var _employees: Array[EmployeeBase] = [] # 雇用している従業員
var _watch_interval: float = 0.1
var _last_id = 0 # 最後に雇用した従業員の ID


func _ready() -> void:
	_start_watch_employees()


func get_employee(no: int) -> EmployeeBase:
	if no < _employees.size():
		return _employees[no]
	else:
		return null

func get_employees() -> Array[EmployeeBase]:
	return _employees


func add_employee(employee: EmployeeBase) -> void:
	_last_id += 1
	employee.id = _last_id
	_employees.append(employee)


func add_task(employee: EmployeeBase, material: MaterialBase) -> void:
	employee.add_task(material)

func remove_task(employee: EmployeeBase, material: MaterialBase) -> void:
	employee.remove_task(material)


func _start_watch_employees() -> void:
	var task_tween = create_tween()
	task_tween.set_loops()
	task_tween.tween_interval(_watch_interval)
	task_tween.tween_callback(_watch_employees)

func _watch_employees() -> void:
	for employee in _employees:
		employee.work()
