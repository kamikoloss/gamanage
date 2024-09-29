# CLI でゲームを操作するためのクラス
extends Node


enum LineColor {
	WHITE, GRAY,
	RED, BLUE, GREEN,
	YELLOW, MAGENTA, CYAN,
}


# https://docs.godotengine.org/ja/4.x/classes/class_color.html#constants
const LINE_COLOR_STRING = {
	LineColor.WHITE: "WHITE", LineColor.GRAY: "GRAY",
	LineColor.RED: "RED", LineColor.BLUE: "BLUE", LineColor.GREEN: "GREEN",
	LineColor.YELLOW: "YELLOW", LineColor.MAGENTA: "MAGENTA", LineColor.CYAN: "CYAN",
}

const HELP_DESCRIPTIONS_LV0 = {
	"debug": "	(デバッグ用コマンドの一覧を表示します)",
	"help": "	すべてのコマンドの一覧を表示します",
	"show": "	(データ確認用コマンドの一覧を表示します)",
	"task": "	(従業員タスク設定用コマンドの一覧を表示します)",
}
const HELP_DESCRIPTIONS_LV1 = {
	"debug": {
		"x <ratio>": "	ゲームの進行速度を変更します",
	},
	"show": {
		"emp <no>": "	従業員の詳細を表示します",
		"mat <id>": "	素材の詳細を表示します",
	},
	"task": {
		"add <emp-id> <mat-id>": "		従業員のタスクを追加します",
		"remove <emp-id> <mat-id>": "	従業員のタスクを消去します",
	},
}


@export var _line_edit: LineEdit
@export var _label_1: RichTextLabel
#@export var _label_2: RichTextLabel
@export var _label_3a: RichTextLabel
@export var _label_3b: RichTextLabel
@export var _label_4: RichTextLabel


var _version = "v0.0.0"
var _label_1_lines = []
var _label_4_lines = []

var _command_history = []
var _command_history_index = 0


func _ready() -> void:
	_line_edit.grab_focus()

	# Main
	_line_main("----------------------------------------------------------------", LineColor.GRAY)
	_line_main("GAMANAGE (CLI Mode) %s" % [_version], LineColor.GRAY)
	_line_main("\"help\" と入力するとコマンド一覧が表示されます", LineColor.GRAY)
	_line_main("----------------------------------------------------------------", LineColor.GRAY)
	# Log
	_line_log("ここには行動ログやヒントが表示されます", "System", LineColor.CYAN)
	_line_log("ヒント: 上下キーで過去のコマンドを再利用できます", "System", LineColor.CYAN)

	# 最初の従業員を追加する
	var employee = EmployeeBase.new("インディー太郎")
	employee.task_changed.connect(_on_employee_task_changed)
	EmployeeManager.add_employee(employee)


func _process(delta: float) -> void:
	_process_refresh_label_3()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_ENTER:
				_line_main("$ %s" % [_line_edit.text]) # 打ったコマンド自体を表示する
				_exec_command(_line_edit.text)
				_line_edit.text = ""
			KEY_UP:
				if _command_history.is_empty():
					return
				_command_history_index = clampi(_command_history_index - 1, 0, _command_history.size() - 1)
				_line_edit.text = _command_history[_command_history_index]
			KEY_DOWN:
				if _command_history.is_empty():
					return
				_command_history_index = clampi(_command_history_index + 1, 0, _command_history.size() - 1)
				_line_edit.text = _command_history[_command_history_index]


# -------------------------------- signal --------------------------------

func _on_employee_task_changed(employee: EmployeeBase, material: MaterialBase) -> void:
	var line = ""
	if employee.has_to_do:
		line = "%s を作るぞ！" % material.screen_name
	else:
		line = "やることがない……"
	_line_log(line, employee.screen_name)


# -------------------------------- Label --------------------------------

func _process_refresh_label_3() -> void:
	# 3a
	var label_3a_lines = []
	label_3a_lines.append("<会社>")
	label_3a_lines.append_array([
		"プレイ時間	%s (x%s)" % [GameManager.uptime_string, GameManager.time_scale],
		"会社資金		%s" % [GameManager.company_money],
	])
	label_3a_lines.append("\n")

	label_3a_lines.append("<従業員>")
	label_3a_lines.append("NO, Mntl/Comm/Engn/Art_/MBTI")
	var employee_no = 0
	for employee in EmployeeManager.get_employees():
		label_3a_lines.append("%2s, %3s%s/%3s%s/%3s%s/%3s%s/%s" % [
			employee_no,
			employee.specs[0], employee.specs_rank_string[0],
			employee.specs[1], employee.specs_rank_string[1],
			employee.specs[2], employee.specs_rank_string[2],
			employee.specs[3], employee.specs_rank_string[3],
			employee.mbti_string,
		])
		employee_no += 1
	_label_3a.text = "\n".join(label_3a_lines)

	# 3b
	var label_3b_lines = []
	label_3b_lines.append("<素材>")
	label_3b_lines.append("ID, Now_/Max_, Name") 
	for material in MaterialManager.unlocked_materials:
		var amount = MaterialManager.get_material_amount(material.type)
		label_3b_lines.append("%2s, %4s/%4s, %s" % [material.type, amount, material.max_amount, material.screen_name])
	_label_3b.text = "\n".join(label_3b_lines)


# -------------------------------- CLI --------------------------------

# CLI に文字列を表示する
func _line(line: String, label_id: int = 1, color: LineColor = LineColor.WHITE) -> void:
	var color_string = LINE_COLOR_STRING[color]
	var colored_line = "[color=%s]" % [color_string] + line + "[/color]"
	match label_id:
		1:
			_label_1_lines.append(colored_line)
			_label_1.text = "\n".join(_label_1_lines)
			_label_1.scroll_to_line(9999)
		4:
			_label_4_lines.append(colored_line)
			_label_4.text = "\n".join(_label_4_lines)
			_label_4.scroll_to_line(9999)

func _line_main(line: String, color: LineColor = LineColor.WHITE) -> void:
	_line(line, 1, color)

func _line_log(line: String, name: String, color: LineColor = LineColor.WHITE) -> void:
	#var datetime_dict = Time.get_datetime_dict_from_system()
	#var datetime_string = Time.get_datetime_string_from_datetime_dict(datetime_dict, true)
	#var line_with_name = "%s [%s] %s" % [datetime_string, name, line]
	var line_with_name = "[%s] %s" % [name, line]
	_line(line_with_name, 4, color)


func _exec_command(line: String) -> void:
	# コマンドを whitespace で分割する
	# whitespace 自体は split() の第2引数によって除外される
	var words: Array[String] = []
	words.assign(Array(line.split(" ", false)))

	# コマンドを何も入力せずに Enter を押したとき:
	# 何もせずに終了する (単なる改行送りになる)
	if words.size() == 0:
		return

	# コマンド履歴を追加する
	_command_history.append(line)
	_command_history_index = _command_history.size()

	# コマンドを実行する
	# 有効なコマンドに突き当たったら return する
	match words[0]:
		"debug":
			if words.size() <= 1:
				return _help(words)
			match words[1]:
				"x":
					if words.size() <= 2:
						return _help(words)
					GameManager.time_scale = int(words[2])
					return
		"help":
			return _help(words)
		"show":
			if words.size() <= 2:
				return _help(words)
			match words[1]:
				"emp":
					return _show_employee(int(words[2]))
				"mat":
					return _show_material(int(words[2]))
		"task":
			if words.size() <= 2:
				return _help(words)
			match words[1]:
				"add":
					return _task_add(int(words[2]), int(words[3]))
				"remove":
					return _task_remove(int(words[2]), int(words[3]))

	# コマンドリストにないコマンドが入力されたとき: エラーを表示する
	_line_main("%s: invalid command!" % line, LineColor.RED)


# ---------------- CLI help ----------------

func _help(words: Array[String]) -> void:
	var lines = []

	if words[0] == "help":
		var descs = HELP_DESCRIPTIONS_LV0
		lines = descs.keys().map(func(v): return v + descs[v])
	else:
		var descs = HELP_DESCRIPTIONS_LV1[words[0]]
		lines = descs.keys().map(func(v): return "%s %s" % [words[0], v] + descs[v])

	_line_main("\n".join(lines), LineColor.YELLOW)


# ---------------- CLI show ----------------

func _show_employee(employee_no: int) -> void:
	var employee = EmployeeManager.get_employee(employee_no)

	if employee == null:
		_line_main("employee %s: not found!" % employee_no, LineColor.RED)
		return

	_line_main("<プロフィール>")
	_line_employee(employee)
	_line_main("<現在設定中のタスク>")
	_line_employee_task(employee)


func _line_employee(employee: EmployeeBase) -> void:
	if employee == null:
		return

	var lines = [
		"名前			%s" % [employee.screen_name],
		"性格			%s (%s)" % [employee.mbti_roll, employee.mbti_string],
		"月単価			%s" % [employee.cost],
		"精神力			%3s (%s)" % [employee.specs[0], employee.specs_rank_string[0]],
		"コミュ力			%3s (%s)" % [employee.specs[1], employee.specs_rank_string[1]],
		"エンジニア力		%3s (%s)" % [employee.specs[2], employee.specs_rank_string[2]],
		"アート力			%3s (%s)" % [employee.specs[3], employee.specs_rank_string[3]],
	]
	_line_main("\n".join(lines))

func _line_employee_task(employee: EmployeeBase) -> void:
	if employee._task_list.is_empty():
		_line_main("なし")
		return

	_line_main("種類, 対象")
	for task in employee._task_list:
		var task_type = EmployeeBase.TaskType.keys()[task[0]]
		var material = MaterialManager.get_material_data(task[1])
		var emoloyee_task_line = "%s, %s" % [task_type, material_type]
		_line_main(emoloyee_task_line)


func _show_material(material_type: int) -> void:
	if not CoreMaterial.MATERIAL_DATA.keys().has(material_type):
		_line_main("material %s: not found!" % material_type, LineColor.RED)
		return

	var material = CoreMaterial.MATERIAL_DATA[material_type]
	_line_material(material)


func _line_material(material: Dictionary) -> void:
	# 加工: in + out
	var in_out = ""
	if material.has("in"):
		var in_materials = material["in"].map(func(v):
			var material_name = CoreMaterial.MATERIAL_DATA[v[0]]["name"]
			return "%s x%s" % [material_name, v[1]]
		)
		in_out = " + ".join(in_materials) + " =従業員=> %s" % [material["out"]]
	# 生産: out のみ
	elif material.has("out"):
		in_out = "従業員 => %s" % [material["out"]]

	var goal = "なし"
	if material.has("goal"):
		goal = material["goal"]

	var lines = [
		"名前		%s" % [material["name"]],
		"生産手段		%s" % [in_out],
		"最大保持数	%s" % [material["max"]],
		"完成基準		%s" % [goal],
	]
	_line_main("\n".join(lines))


# ---------------- CLI task ----------------

func _task_add(employee_no: int, material_type: int) -> void:
	EmployeeManager.add_task_material(employee_no, material_type)
	_line_employee_task(EmployeeManager.get_employee(employee_no))

func _task_remove(employee_no: int, material_type: int) -> void:
	EmployeeManager.remove_task_material(employee_no, material_type)
	_line_employee_task(EmployeeManager.get_employee(employee_no))
