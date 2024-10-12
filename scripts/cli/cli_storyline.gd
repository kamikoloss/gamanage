# アンロックなどゲームの流れを管理するクラス
class_name CliStoryline
extends Node


var _cli: Cli

# フラグ群
var _はじめて素材が足りない: bool = false
var _はじめてゲームの素材が足りた: bool = false
var _はじめてゲーム生産が進んだ: bool = false


func _init(cli: Cli) -> void:
	_cli = cli

	# signal
	MaterialManager.material_unlocked.connect(_on_material_unlocked)
	EmployeeManager.employee_task_changed.connect(_on_employee_task_changed)

	# 初期素材をアンロックする
	MaterialManager.unlock_material(MaterialData.MaterialType.D2_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.D3_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.PROGRAM_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.ACTION_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.RPG_1)

	# 初期従業員を追加する
	var employee = EmployeeBase.new("インディー太郎")
	EmployeeManager.add_employee(employee)

	# CLI
	_cli.line_main("----------------------------------------------------------------", Cli.LineColor.GRAY)
	_cli.line_main("GAMANAGE (CLI Mode) %s" % [GameManager.version], Cli.LineColor.GRAY)
	_cli.line_main("\"help\" と入力するとコマンド一覧が表示されます", Cli.LineColor.GRAY)
	_cli.line_main("----------------------------------------------------------------", Cli.LineColor.GRAY)
	_cli.line_log_tips("上下キーで過去のコマンドを再利用できます")


func _on_material_unlocked(material: MaterialData) -> void:
	var line = "%s がアンロックされた！" % [material.screen_name]
	_cli.line_log_system(line)


func _on_employee_task_changed(employee: EmployeeBase, material: MaterialData) -> void:
	var line = ""
	if employee.is_working:
		line = "%s を作るぞ！" % [material.screen_name]
	else:
		line = "やることがない……"
	_cli.line_log(line, employee.screen_name)
