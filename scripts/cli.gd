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
	"help": "	(コマンドの一覧を表示します)",
	"quit": "	ゲームを終了します",
	"show": "	(データ表示用コマンドの一覧を表示します)",
}
const HELP_DESCRIPTIONS_LV1 = {
	"debug": {
		"time-scale <x>": "	ゲームの進行速度を変更します",
	},
	"show": {
		"employees": "		従業員の一覧を表示します",
		"employees <id>": "	従業員の詳細を表示します",
		"materials": "		素材の一覧を表示します",
		"materials <id>": "	素材の詳細を表示します",
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

	# Log
	#for color in LINE_COLOR_STRING.keys():
	#	_append_line_log("color debug.", "Debug", color)
	_append_line_log("ここにはヒントや行動ログが表示されます", "System", LineColor.CYAN)


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
	var words = Array(line.split(" ", false))

	# コマンドを何も入力せずに Enter を押したとき: 何もせずに終了する (単なる改行送りになる)
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
		"quit":
			is_valid_command = true
			get_tree().quit()
		"show":
			if words.size() <= 1:
				is_valid_command = true
				_help(words)
			else:
				match words[1]:
					"employees":
						if words.size() <= 2:
							is_valid_command = true
							# list emp
						else:
							is_valid_command = true
							# show emp
					"materials":
						if words.size() <= 2:
							is_valid_command = true
							_show_materials()
						else:
							is_valid_command = true
							_show_materials(int(words[2]))

	# コマンドリストにないコマンドが入力されたとき: エラーを表示して終了する
	if not is_valid_command:
		_append_line_main("%s: invalid command!" % line, LineColor.RED)
		return

func _help(words: Array) -> void:
	var help_texts = []

	if words[0] == "help":
		var descs = HELP_DESCRIPTIONS_LV0
		help_texts = descs.keys().map(func(v): return v + descs[v])
	elif words.size() == 1:
		var descs = HELP_DESCRIPTIONS_LV1[words[0]]
		help_texts = descs.keys().map(func(v): return "%s %s" % [words[0], v] + descs[v])
	elif words.size() == 2:
		pass

	var help_text = "\n".join(help_texts)
	_append_line_main(help_text, LineColor.YELLOW)


func _show_employees(id: int = -1) -> void:
	pass


func _show_materials(type: int = -1) -> void:
	var line = "id, name, 生産方法"
	_append_line_main(line)	

	if type == -1:
		for _type in CoreMaterial.Type.values():
			_show_materials_append_line(_type)
	else:
		_show_materials_append_line(type)

func _show_materials_append_line(type: int) -> void:
	var material = CoreMaterial.MATERIAL_DATA[type]
	var how_to_out = ""
	if material.has("in"):
		var in_materials = material["in"].map(func(v):
			var material_name = CoreMaterial.MATERIAL_DATA[v[0]]["name"]
			return "%s x%s" % [material_name, v[1]]
		)
		how_to_out = " + ".join(in_materials) + " => %s" % [material["out"]]
	else:
		how_to_out = "従業員による生産"

	var line = "%s, %s, %s" % [type, material["name"], how_to_out]
	_append_line_main(line)
