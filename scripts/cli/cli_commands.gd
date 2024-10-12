# CLI のコマンドをまとめたクラス
class_name CliCommands
extends Node


const HELP_DESCRIPTIONS_LV0 = {
	"debug":    "	デバッグ用のコマンドの一覧を表示します",
	"emp":    "		従業員系のコマンドの一覧を表示します",
	"help":    "	すべてのコマンドの一覧を表示します",
	"mat":    "		素材系のコマンドの一覧を表示します",
	"sale":    "	ゲーム販売系のコマンドの一覧を表示します",
	"task":    "	タスク設定用のコマンドの一覧を表示します",
}

const HELP_DESCRIPTIONS_LV1 = {
	"debug": {
		"c <code>":    "	チートを実行します",
		"x <ratio>":    "	ゲームの進行速度を変更します",
	},
	"emp": {
		"show <emp-id>": "	従業員の詳細を表示します",
	},
	"mat": {
		"show <mat-id>": "	素材の詳細を表示します",
	},
	"sale": {
		"<mat-id> <amount>": "	ゲームを販売します",
	},
	"task": {
		"add <emp-id> <mat-id>":    "	従業員のタスクを追加します",
		"rem <emp-id>":    "			従業員のすべてのタスクを削除します",
		"rem <emp-id> <mat-id>":    "	従業員の特定のタスクを削除します",
	},
}


var _cli: Cli


func _init(cli: Cli) -> void:
	_cli = cli


# コマンドを実行する
# 有効なコマンドに突き当たったら return する
func exec_command(words: Array[String]) -> void:
	match words[0]:
		"debug":
			if words.size() <= 1:
				return _help(words)
			match words[1]:
				"c":
					if words.size() <= 2:
						return _help(words)
					return _debug_cheat(words[2])
				"x":
					if words.size() <= 2:
						return _help(words)
					GameManager.time_scale = int(words[2])
					return
		"emp":
			if words.size() <= 1:
				return _help(words)
			match words[1]:
				"show":
					if words.size() <= 2:
						return _help(words)
					return _show_employee(int(words[2]))
		"help":
			return _help(words)
		"mat":
			if words.size() <= 1:
				return _help(words)
			match words[1]:
				"show":
					if words.size() <= 2:
						return _help(words)
					return _show_material(int(words[2]))
		"sale":
			pass
		"task":
			if words.size() <= 1:
				return _help(words)
			match words[1]:
				"add":
					if words.size() <= 3:
						return _help(words)
					return _task_add(int(words[2]), int(words[3]))
				"rem":
					if words.size() <= 2:
						return _help(words)
					if words.size() <= 3:
						return _task_remove_all(int(words[2]))
					return _task_remove(int(words[2]), int(words[3]))

	# コマンドリストにないコマンドが入力されたとき: エラーを表示する
	_cli.line_main("invalid command!", Cli.LineColor.RED)


# ---------------- debug ----------------

func _debug_cheat(code: String) -> void:
	match code:
		# 素材の所持数 MAX
		"max-amo":
			for material: MaterialData in MaterialManager.get_materials():
				MaterialManager.set_material_amount(material.type, 9999)
			return
		# 素材の所持最大数 突破
		"no-max":
			for material: MaterialData in MaterialManager.get_materials():
				material.max_amount = 9999
			return

	# 不正なチートコードが入力されたとき: エラーを表示する
	_cli.line_main("invalid code!", Cli.LineColor.RED)


# ---------------- help ----------------

func _help(words: Array[String]) -> void:
	var lines = []

	if words[0] == "help":
		var descs = HELP_DESCRIPTIONS_LV0
		lines = descs.keys().map(func(v): return v + descs[v])
	else:
		var descs = HELP_DESCRIPTIONS_LV1[words[0]]
		lines = descs.keys().map(func(v): return "%s %s" % [words[0], v] + descs[v])

	_cli.line_main("\n".join(lines), Cli.LineColor.YELLOW)


# ---------------- emp ----------------

func _show_employee(employee_id: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return _cli.line_main("employee %s: not found!" % employee_id, Cli.LineColor.RED)

	_cli.line_main("＜プロフィール＞")
	_line_employee(employee)
	_cli.line_main("＜現在設定中のタスク＞")
	_line_employee_task(employee)


func _line_employee(employee: EmployeeBase) -> void:
	var lines = [
		"名前   			%s" % [employee.screen_name],
		"性格   			%s (%s)" % [employee.mbti_roll, employee.mbti_string],
		"月単価   		%s" % [employee.cost],
		"精神力   		%3s (%s)" % [employee.specs[0], employee.specs_rank_string[0]],
		"コミュ力   		%3s (%s)" % [employee.specs[1], employee.specs_rank_string[1]],
		"エンジニア力   	%3s (%s)" % [employee.specs[2], employee.specs_rank_string[2]],
		"アート力   		%3s (%s)" % [employee.specs[3], employee.specs_rank_string[3]],
	]
	_cli.line_main("\n".join(lines))

func _line_employee_task(employee: EmployeeBase) -> void:
	if not employee.has_task:
		_cli.line_main("なし")
		return

	_cli.line_main("ID, 生産素材")
	for task_material: MaterialData in employee.get_tasks():
		var line = "%2s, %s" % [task_material.type, task_material.screen_name]
		_cli.line_main(line)


# ---------------- mat ----------------

func _show_material(material_type: int) -> void:
	var material = MaterialManager.get_material(material_type)
	if material == null:
		return _cli.line_main("material %s: not found!" % material_type, Cli.LineColor.RED)

	_line_material(material)


func _line_material(material: MaterialData) -> void:
	var in_out = ""
	if material.input.is_empty():
		in_out = "従業員 => %s" % [material.output]
	else:
		var inputs = material.input.map(func(v):
			var input_material = MaterialManager.get_material(v[0])
			return "%s x%s" % [input_material.screen_name, v[1]]
		)
		in_out = " + ".join(inputs) + " =従業員=> %s" % [material.output]

	var goal = "なし"
	if 0 < material.goal_base_amount:
		goal = material.goal_base_amount

	var lines = [
		"名前   			%s" % [material.screen_name],
		"生産手段   		%s" % [in_out],
		"最大保持数   	%s" % [material.max_amount],
		"完成基準   		%s" % [goal],
	]
	_cli.line_main("\n".join(lines))


# ---------------- task ----------------

func _task_add(employee_id: int, material_type: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return _cli.line_main("employee %s: not found!" % employee_id, Cli.LineColor.RED)
	var material = MaterialManager.get_material(material_type)
	if material == null:
		return _cli.line_main("material %s: not found!" % material_type, Cli.LineColor.RED)

	EmployeeManager.add_task(employee_id, material_type)
	_line_employee_task(employee)


func _task_remove_all(employee_id: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return _cli.line_main("employee %s: not found!" % employee_id, Cli.LineColor.RED)

	for task_material: MaterialData in employee.get_tasks():
		EmployeeManager.remove_task(employee_id, task_material.type)
	_line_employee_task(employee)


func _task_remove(employee_id: int, material_type: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return _cli.line_main("employee %s: not found!" % employee_id, Cli.LineColor.RED)
	var material = MaterialManager.get_material(material_type)
	if material == null:
		return _cli.line_main("material %s: not found!" % material_type, Cli.LineColor.RED)

	EmployeeManager.remove_task(employee_id, material_type)
	_line_employee_task(employee)
