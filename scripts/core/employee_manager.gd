# ゲーム上の従業員を管理するクラス
extends Node


# 従業員が進めているタスクが変わったとき
signal employee_task_changed # (EmployeeBase, MaterialData)


var _employees: Dictionary = {} # 雇用している従業員のリスト { <id>: EmployeeBase }
var _watch_interval: float = 0.1 # 従業員を監視する周期 (秒)
var _last_id = 0 # 最後に雇用した従業員の ID


func _ready() -> void:
	_start_watch_employees()


func get_employee(id: int) -> EmployeeBase:
	if _employees.keys().has(id):
		return _employees[id]
	else:
		return null

func get_employees() -> Array:
	return _employees.values()

func add_employee(employee: EmployeeBase) -> void:
	_last_id += 1
	employee.id = _last_id
	_employees[_last_id] = employee

	employee.task_changed.connect(func(emp, mat): employee_task_changed.emit(emp, mat))

func remove_employee(employee_id: int) -> void:
	pass
	# TODO: signal 切断


func add_task(employee_id: int, material_type: int) -> void:
	var employee = get_employee(employee_id)
	var material = MaterialManager.get_material(material_type)
	employee.add_task(material)

func remove_task(employee_id: int, material_type: int) -> void:
	var employee = get_employee(employee_id)
	var material = MaterialManager.get_material(material_type)
	employee.remove_task(material)


func _start_watch_employees() -> void:
	var task_tween = create_tween()
	task_tween.set_loops()
	task_tween.tween_interval(_watch_interval)
	task_tween.tween_callback(_watch_employees)

func _watch_employees() -> void:
	for employee: EmployeeBase in _employees.values():
		employee.work()
