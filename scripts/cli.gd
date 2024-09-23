# CLI でゲームを操作するためのクラス
extends Node


enum LineColor {
	WHITE,
	GRAY,
	RED,
	BLUE,
	GREEN,
	YELLOW,
	MAGENTA,
	CYAN,
}


# https://docs.godotengine.org/ja/4.x/classes/class_color.html#constants
const LINE_COLOR_STRING = {
	LineColor.WHITE: "WHITE",
	LineColor.GRAY: "GRAY",
	LineColor.RED: "RED",
	LineColor.BLUE: "BLUE",
	LineColor.GREEN: "GREEN",
	LineColor.YELLOW: "YELLOW",
	LineColor.MAGENTA: "MAGENTA",
	LineColor.CYAN: "CYAN",
}

const HELP_DESCRIPTIONS_LV0 = {
	"debug": "	(デバッグ用コマンドの一覧を表示します)",
	"help": "	すべてのコマンドの一覧を表示します",
	"list": "	(マスターデータ確認用のコマンドの一覧を表示します)",
	"set": "	(設定用コマンドの一覧を表示します)",
	"show": "	(所持リソース確認用コマンドの一覧を表示します)",
}
const HELP_DESCRIPTIONS_LV1 = {
	"debug": {
		"time-scale <x>": "	ゲームの進行速度を変更します",
	},
	"list": {
		"mat": "		マスターデータの素材の一覧を表示します",
		"mat <type>": "	マスターデータの素材の詳細を表示します",
	},
	"set": {
		"task <emp-id> <mat-type>": "	従業員に素材生産のタスクを設定します",
		"task <emp-id> <mat-id>": "		従業員にデプロイのタスクを設定します"
	},
	"show": {
		"emp": "		雇用している従業員の一覧を表示します",
		"emp <id>": "	雇用している従業員の詳細を表示します",
		"mat": "		所持している素材の一覧を表示します",
		"mat <id>": "	所持している素材の詳細を表示します",
	},
}


@export var _core: Core

@export var _line_edit: LineEdit
@export var _label_1: RichTextLabel
#@export var _label_2: RichTextLabel
@export var _label_3a: RichTextLabel
@export var _label_3b: RichTextLabel
@export var _label_4: RichTextLabel


var _version = "v0.0.0"
var _label_1_lines = []
var _label_4_lines = []


func _ready() -> void:
	_line_edit.grab_focus()

	# Main
	_append_line_main("----------------------------------------------------------------", LineColor.GRAY)
	_append_line_main("GAMANAGE (CLI Mode) %s" % [_version], LineColor.GRAY)
	_append_line_main("\"help\" と入力するとコマンド一覧が表示されます", LineColor.GRAY)
	_append_line_main("----------------------------------------------------------------", LineColor.GRAY)
	_append_line_main("\n")

	# Log
	_append_line_log("ここには行動ログやヒントが表示されます", "System", LineColor.CYAN)

	# 最初の従業員を追加する
	var employee = CoreEmployeeBase.new("インディー太郎")
	_core.add_employee(employee)


func _process(delta: float) -> void:
	# 3a: ステータス
	var label_3a_lines = [
		"プレイ時間	%s (x%s)" % [_core.uptime_string, _core.time_scale],
		"会社資金		%s" % [_core.company_money],
	]
	_label_3a.text = "\n".join(label_3a_lines)
	# 3b: 素材
	var label_3b_lines = []
	_label_3b.text = "\n".join(label_3b_lines)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_ENTER:
				_append_line_main("$ " + _line_edit.text) # 打ったコマンド自体を表示する
				_exec_command(_line_edit.text)
				_line_edit.text = ""
			# TODO: UP キーで履歴出す


func _append_line(line: String, label_id: int = 1, color: LineColor = LineColor.WHITE) -> void:
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

func _append_line_main(line: String, color: LineColor = LineColor.WHITE) -> void:
	_append_line(line, 1, color)

func _append_line_log(line: String, name: String, color: LineColor = LineColor.WHITE) -> void:
	#var datetime_dict = Time.get_datetime_dict_from_system()
	#var datetime_string = Time.get_datetime_string_from_datetime_dict(datetime_dict, true)
	#var line_with_name = "%s [%s] %s" % [datetime_string, name, line]
	var line_with_name = "[%s] %s" % [name, line]
	_append_line(line_with_name, 4, color)


func _exec_command(line: String) -> void:
	# コマンドを whitespace で分割する
	# whitespace 自体は split() の第2引数によって除外される
	var words: Array[String] = []
	words.assign(Array(line.split(" ", false)))

	# コマンドを何も入力せずに Enter を押したとき:
	# 何もせずに終了する (単なる改行送りになる)
	if words.size() == 0:
		return

	# コマンドを実行する
	# 有効なコマンドに突き当たったら is_valid_command を true にする
	var is_valid_command = false
	match words[0]:
		"debug":
			if words.size() <= 1:
				is_valid_command = true
				_help(words)
			else:
				match words[1]:
					"time-scale":
						if words.size() <= 2:
							is_valid_command = true
							_help(words)
						else:
							is_valid_command = true
							_core.time_scale = int(words[2])
		"help":
			is_valid_command = true
			_help(words)
		"list":
			if words.size() <= 1:
				is_valid_command = true
				_help(words)
			else:
				match words[1]:
					"mat":
						if words.size() <= 2:
							is_valid_command = true
							_list_materials()
						else:
							is_valid_command = true
							_list_materials(int(words[2]))
		"set":
			if words.size() <= 1:
				is_valid_command = true
				_help(words)
			else:
				match words[1]:
					"task":
						if words.size() <= 2:
							is_valid_command = true
							_help(words)
						else:
							is_valid_command = true
							_set_task(int(words[2]), int(words[3]))
		"show":
			if words.size() <= 1:
				is_valid_command = true
				_help(words)
			else:
				match words[1]:
					"emp":
						if words.size() <= 2:
							is_valid_command = true
							_show_employees()
						else:
							is_valid_command = true
							_show_employees(int(words[2]))
					"mat":
						if words.size() <= 2:
							is_valid_command = true
							_show_materials()
						else:
							is_valid_command = true
							_show_materials(int(words[2]))

	# コマンドリストにないコマンドが入力されたとき: エラーを表示する
	if not is_valid_command:
		_append_line_main("%s: invalid command!" % line, LineColor.RED)

	# 1行開ける
	_append_line_main("\n") 


# -------------------------------- help --------------------------------

func _help(words: Array[String]) -> void:
	var help_lines = []

	if words[0] == "help":
		var descs = HELP_DESCRIPTIONS_LV0
		help_lines = descs.keys().map(func(v): return v + descs[v])
	elif words.size() == 1:
		var descs = HELP_DESCRIPTIONS_LV1[words[0]]
		help_lines = descs.keys().map(func(v): return "%s %s" % [words[0], v] + descs[v])
	elif words.size() == 2:
		pass

	_append_line_main("\n".join(help_lines), LineColor.YELLOW)


# -------------------------------- list --------------------------------

func _list_materials(type: int = -1) -> void:
	# 一覧表示
	if type == -1:
		_append_line_main("Type, 名前, 生産手段 (/min)") 
		for _type in CoreMaterial.Type.values():
			_append_line_material(_type)
	# TODO: 詳細表示
	else:
		_append_line_main("TODO!!", LineColor.MAGENTA)
		pass

func _append_line_material(type: int) -> void:
	var material = CoreMaterial.MATERIAL_DATA[type]
	var how_to_out = ""

	# 従業員加工: in + out
	if material.has("in"):
		var in_materials = material["in"].map(func(v):
			var material_name = CoreMaterial.MATERIAL_DATA[v[0]]["name"]
			return "%s x%s" % [material_name, v[1]]
		)
		how_to_out = " + ".join(in_materials) + " =従業員=> %s" % [material["out"]]
	# 従業員生産: out のみ
	elif material.has("out"):
		how_to_out = "従業員 => %s" % [material["out"]]

	var line = "%s, %s, %s" % [type, material["name"], how_to_out]
	_append_line_main(line)

# -------------------------------- show --------------------------------

func _set_task(employee_id: int, material_type: int) -> void:
	var employee = _core.employees[employee_id]
	employee.add_task_material(material_type)
	_append_line_employee_task(employee)


# -------------------------------- show --------------------------------

func _show_employees(id: int = -1) -> void:
	# 一覧表示
	if id == -1:
		_append_line_main("ID, 名前, 月単価, 稼働率")
		for _id in range(_core.employees.size()):
			var employee: CoreEmployeeBase = _core.employees[_id]
			var employee_line = "%s, %s, %s, %s" % [_id, employee.screen_name, employee.cost, "TODO!!"]
			_append_line_main(employee_line)
	# 詳細表示
	else:
		var employee: CoreEmployeeBase = _core.employees[id]
		_append_line_main("<プロフィール>")
		_append_line_employee_profile(employee)
		_append_line_main("<現在設定中のタスク>")
		_append_line_employee_task(employee)

func _append_line_employee_profile(employee: CoreEmployeeBase) -> void:
	var employee_spec_lines = [
		"名前			%s" % [employee.screen_name],
		"性格			%s (%s)" % [employee.mbti_roll, employee.mbti_string],
		"月単価			%s" % [employee.cost],
		"精神力			%s (%03d)" % [employee.get_rank_string(employee.spec_mental), employee.spec_mental],
		"コミュ力			%s (%03d)" % [employee.get_rank_string(employee.spec_communication), employee.spec_communication],
		"エンジニア力		%s (%03d)" % [employee.get_rank_string(employee.spec_engineering), employee.spec_engineering],
		"アート力			%s (%03d)" % [employee.get_rank_string(employee.spec_art), employee.spec_art],
	]
	_append_line_main("\n".join(employee_spec_lines))

func _append_line_employee_task(employee: CoreEmployeeBase) -> void:
	_append_line_main("種類, 対象, 稼働率")
	for task in employee.task_list:
		var task_type = CoreEmployeeBase.TaskType.keys()[task[0]]
		var material_type = CoreMaterial.MATERIAL_DATA[task[1]]["name"]
		var emoloyee_task_line = "%s, %s, %s" % [task_type, material_type, "TODO!!"]
		_append_line_main(emoloyee_task_line)


func _show_materials(type: int = -1) -> void:
	# TODO: 一覧表示
	if type == -1:
		_append_line_main("TODO!!", LineColor.MAGENTA)
		_append_line_main("ID, 名前, 所持数, 増減")
		for _type in CoreMaterial.Type.values():
			pass
	# TODO: 詳細表示
	else:
		_append_line_main("TODO!!", LineColor.MAGENTA)
