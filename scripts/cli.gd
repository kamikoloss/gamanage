extends Node

# NOTE: \t は 半角16文字/全角8文字 が埋まるようにつける


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
	"debug": "	デバッグ用コマンド詳細を表示します",
	"help": "	コマンド一覧を表示します",
	"quit": "	ゲームを終了します",
}
const HELP_DESCRIPTIONS_LV1 = {
	"debug": {
		"time-scale <x>": "	ゲームの進行速度を変更します",
	},
}


@export var _core: Core

@export var _line_edit: LineEdit
@export var _label_1: RichTextLabel
@export var _label_2: RichTextLabel
@export var _label_3: RichTextLabel
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
	_append_line_main("\"<command> help\" と入力するとコマンド詳細が表示されます", LineColor.GRAY)
	_append_line_main("----------------------------------------------------------------", LineColor.GRAY)

	# Log
	# 色テスト
	#for color in LINE_COLOR_STRING.keys():
	#	_append_line_log("color debug.", "Debug", color)
	_append_line_log("ここにはヒントや行動ログが表示されます", "System", LineColor.CYAN)


func _process(delta: float) -> void:
	var label_3_lines = [
		"プレイ時間		%s (x%s)" % [_core.uptime_string, _core.time_scale],
	]
	_label_3.text = "\n".join(label_3_lines)


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
			if words.size() < 2:
				is_valid_command = true
				_exec_command_help(words)
			else:
				match words[1]:
					"time-scale":
						if words.size() < 3:
							is_valid_command = true
							_exec_command("debug")
						else:
							is_valid_command = true
							_core.time_scale = int(words[2])
		"help":
			is_valid_command = true
			_exec_command_help(words)
		"quit":
			is_valid_command = true
			get_tree().quit()

	# コマンドリストにないコマンドが入力されたとき: エラーを表示して終了する
	if not is_valid_command:
		_append_line_main("%s: invalid command!" % line, LineColor.RED)
		return

func _exec_command_help(words: Array) -> void:
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
