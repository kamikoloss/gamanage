# ゲーム上の従業員を管理するクラス
extends Node


var _employees: Array[EmployeeBase] = [] # 雇用している従業員
var _employees_watch_interval: float = 0.1


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
	_employees.append(employee)


func add_task_material(no: int, material_type: MaterialData.Type) -> void:
	var employee = get_employee(no)
	if employee == null:
		return
	employee.add_task_material(material_type)

func remove_task_material(no: int, material_type: MaterialData.Type) -> void:
	var employee = get_employee(no)
	if employee == null:
		return
	employee.remove_task_material(material_type)


func _start_watch_employees() -> void:
	var task_tween = create_tween()
	task_tween.set_loops()
	task_tween.tween_interval(0.1)
	task_tween.tween_callback(_watch_employees)

func _watch_employees() -> void:
	for employee in _employees:
		employee.work()
