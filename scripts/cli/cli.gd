# CLI でゲームを操作するためのクラス
class_name CLI
extends Node


# ================================ 06. enums ================================

enum LineColor {
	WHITE, GRAY,
	RED, BLUE, GREEN,
	YELLOW, MAGENTA, CYAN,
}


# ================================ 07. constants ================================

# https://docs.godotengine.org/ja/4.x/classes/class_color.html#constants
const LINE_COLOR_STRING = {
	LineColor.WHITE: "WHITE", LineColor.GRAY: "GRAY",
	LineColor.RED: "RED", LineColor.BLUE: "BLUE", LineColor.GREEN: "GREEN",
	LineColor.YELLOW: "YELLOW", LineColor.MAGENTA: "MAGENTA", LineColor.CYAN: "CYAN",
}

const HELP_DESCRIPTIONS_LV0 = {
				#
	"debug":    "	(デバッグ用のコマンドの一覧を表示します)",
	"emp":    "		(従業員系のコマンドの一覧を表示します)",
	"help":    "	すべてのコマンドの一覧を表示します",
	"mat":    "		(素材系のコマンドの一覧を表示します)",
	"task":    "	(タスク設定用のコマンドの一覧を表示します)",
}
const HELP_DESCRIPTIONS_LV1 = {
	"debug": {
						#
		"c <code>":     "	チートを実行します",
		"x <ratio>":    "	ゲームの進行速度を変更します",
	},
	"emp": {
		"show <emp-id>": "	従業員の詳細を表示します",
	},
	"task": {
									#
		"add <emp-id> <mat-id>":    "	従業員のタスクを追加します",
		"rem <emp-id>":    "			従業員のすべてのタスクを消去します",
		"rem <emp-id> <mat-id>":    "	従業員の特定のタスクを消去します",
	},
	"mat": {
		"show <mat-id>": "	素材の詳細を表示します",
	},
}

# ================================ 08. @export variables ================================

@export var _line_edit: LineEdit
@export var _label_1: RichTextLabel
#@export var _label_2: RichTextLabel
@export var _label_3a: RichTextLabel
@export var _label_3b: RichTextLabel
@export var _label_4: RichTextLabel


# ================================ 10. private variables ================================

var _label_1_lines = []
var _label_4_lines = []

var _command_history = []
var _command_history_index = 0

 
# ================================ 14. built-in virtual _ready method ================================

func _ready() -> void:
	_line_edit.grab_focus()


# ================================ 15. remaining built-in virtual methods ================================

func _process(delta: float) -> void:
	_process_refresh_label_3()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_ENTER:
				line_main("$ %s" % [_line_edit.text]) # 打ったコマンド自体を表示する
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


# ================================ 16. public Methods ================================

func line_main(line: String, color: LineColor = LineColor.WHITE) -> void:
	_line(line, 1, color)

func line_log(line: String, name: String, color: LineColor = LineColor.WHITE) -> void:
	var line_with_name = "[%s] %s" % [name, line]
	_line(line_with_name, 4, color)

func line_log_system(line: String) -> void:
	line_log(line, "System", LineColor.CYAN)

func line_log_tips(line: String) -> void:
	line_log(line, "Tips", LineColor.GREEN)


# ================================ 17. private methods ================================

# -------------------------------- Label --------------------------------

func _process_refresh_label_3() -> void:
	# 3a
	var label_3a_lines = []
	label_3a_lines.append("＜会社＞")
	label_3a_lines.append_array([
		"プレイ時間   	%s (x%s)" % [GameManager.uptime_string, GameManager.time_scale],
		"会社資金   		%s" % [GameManager.company_money],
	])
	label_3a_lines.append("\n")

	label_3a_lines.append("＜従業員＞")
	label_3a_lines.append("ID, Mntl/Comm/Engn/Art_, Cost, Prog")
	for employee: EmployeeBase in EmployeeManager.get_employees():
		label_3a_lines.append("%2s, %3s%s/%3s%s/%3s%s/%3s%s, %4s, %4s" % [
			employee.id,
			employee.specs[0], employee.specs_rank_string[0],
			employee.specs[1], employee.specs_rank_string[1],
			employee.specs[2], employee.specs_rank_string[2],
			employee.specs[3], employee.specs_rank_string[3],
			employee.cost,
			str(employee.progress_percent) + "%",
		])
	_label_3a.text = "\n".join(label_3a_lines)

	# 3b
	var label_3b_lines = []
	label_3b_lines.append("＜素材＞")
	label_3b_lines.append("ID, Now_/Max_, Name") 
	for material: MaterialData in MaterialManager.get_materials():
		var amount = MaterialManager.get_material_amount(material.type)
		label_3b_lines.append("%2s, %4s/%4s, %s" % [
			material.type,
			amount,
			material.max_amount,
			material.screen_name
		])
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


# 文字列をパースして処理を実行する
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
	line_main("%s: invalid command!" % line, LineColor.RED)


# ---------------- CLI debug ----------------

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
	line_main("%s: invalid code!" % code, LineColor.RED)


# ---------------- CLI help ----------------

func _help(words: Array[String]) -> void:
	var lines = []

	if words[0] == "help":
		var descs = HELP_DESCRIPTIONS_LV0
		lines = descs.keys().map(func(v): return v + descs[v])
	else:
		var descs = HELP_DESCRIPTIONS_LV1[words[0]]
		lines = descs.keys().map(func(v): return "%s %s" % [words[0], v] + descs[v])

	line_main("\n".join(lines), LineColor.YELLOW)


# ---------------- CLI emp ----------------

func _show_employee(employee_id: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return line_main("employee %s: not found!" % employee_id, LineColor.RED)

	line_main("＜プロフィール＞")
	_line_employee(employee)
	line_main("＜現在設定中のタスク＞")
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
	line_main("\n".join(lines))

func _line_employee_task(employee: EmployeeBase) -> void:
	if not employee.has_task:
		line_main("なし")
		return

	line_main("ID, 生産素材")
	for task_material: MaterialData in employee.get_tasks():
		var line = "%2s, %s" % [task_material.type, task_material.screen_name]
		line_main(line)


# ---------------- CLI mat ----------------

func _show_material(material_type: int) -> void:
	var material = MaterialManager.get_material(material_type)
	if material == null:
		return line_main("material %s: not found!" % material_type, LineColor.RED)

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
	line_main("\n".join(lines))


# ---------------- CLI task ----------------

func _task_add(employee_id: int, material_type: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return line_main("employee %s: not found!" % employee_id, LineColor.RED)
	var material = MaterialManager.get_material(material_type)
	if material == null:
		return line_main("material %s: not found!" % material_type, LineColor.RED)

	EmployeeManager.add_task(employee_id, material_type)
	_line_employee_task(employee)


func _task_remove_all(employee_id: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return line_main("employee %s: not found!" % employee_id, LineColor.RED)

	for task_material: MaterialData in employee.get_tasks():
		EmployeeManager.remove_task(employee_id, task_material.type)
	_line_employee_task(employee)


func _task_remove(employee_id: int, material_type: int) -> void:
	var employee = EmployeeManager.get_employee(employee_id)
	if employee == null:
		return line_main("employee %s: not found!" % employee_id, LineColor.RED)
	var material = MaterialManager.get_material(material_type)
	if material == null:
		return line_main("material %s: not found!" % material_type, LineColor.RED)

	EmployeeManager.remove_task(employee_id, material_type)
	_line_employee_task(employee)
