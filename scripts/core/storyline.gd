# アンロックなどゲームの流れを管理するクラス
class_name Storyline
extends Node

@export var _cli: CLI


func _ready() -> void:
	# 初期素材をアンロックする
	MaterialManager.unlock_material(MaterialData.MaterialType.D2_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.D3_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.PROGRAM_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.ACTION_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.RPG_1)

	# 初期従業員を追加する
	var employee = EmployeeBase.new("インディー太郎")
	employee.task_changed.connect(_on_employee_task_changed)
	EmployeeManager.add_employee(employee)

	# CLI
	_cli.line_main("----------------------------------------------------------------", CLI.LineColor.GRAY)
	_cli.line_main("GAMANAGE (CLI Mode) %s" % [GameManager.version], CLI.LineColor.GRAY)
	_cli.line_main("\"help\" と入力するとコマンド一覧が表示されます", CLI.LineColor.GRAY)
	_cli.line_main("----------------------------------------------------------------", CLI.LineColor.GRAY)
	_cli.line_log_system("ここには行動ログやヒントが表示されます")
	_cli.line_log_system("ヒント: 上下キーで過去のコマンドを再利用できます")


func _on_employee_task_changed(employee: EmployeeBase, material: MaterialData) -> void:
	var line = ""
	if employee.is_working:
		line = "%s を作るぞ！" % [material.screen_name]
	else:
		line = "やることがない……"
	_cli.line_log(line, employee.screen_name)
