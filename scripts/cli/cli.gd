# CLI でゲームを操作するためのクラス
class_name Cli
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

\
@export var _line_edit: LineEdit
@export var _label_1: RichTextLabel
@export var _label_3a: RichTextLabel
@export var _label_3b: RichTextLabel
@export var _label_4: RichTextLabel


var _cli_commands: CliCommands
var _cli_storyline: CliStoryline

var _label_1_lines: Array[String] = []
var _label_4_lines: Array[String] = []
var _command_history: Array[String] = []
var _command_history_index: int = 0

var _is_dialogue_mode: bool = false # 対話モード中か
var _dialogue_help_texts: Array[String] = [] # 対話モードで表示されるヘルプ
var _dialogue_input_words: Array[String] = [] # 対話モードで入力した単語


func _ready() -> void:
	_line_edit.grab_focus()

	_cli_commands = CliCommands.new(self)
	_cli_storyline = CliStoryline.new(self)


func _process(delta: float) -> void:
	_process_refresh_label()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_ENTER:
				line_main("$ %s" % [_line_edit.text]) # 打ったコマンド自体を表示する
				if _is_dialogue_mode:
					continue_dialogue(_line_edit.text)
				else:
					_exec_command(_line_edit.text)
				_line_edit.clear()
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


func line_main(line: String, color: LineColor = LineColor.WHITE) -> void:
	_line(line, 1, color)

func line_log(line: String, name: String, color: LineColor = LineColor.WHITE) -> void:
	var line_with_name = "[%s] %s" % [name, line]
	_line(line_with_name, 4, color)

func line_log_system(line: String) -> void:
	line_log(line, "System", LineColor.CYAN)

func line_log_tips(line: String) -> void:
	line_log(line, "Tips", LineColor.GREEN)


# 会話モードを開始する
# help_texts の長さは入力される単語数と同じにする
func start_dialogue(base_command: String, help_texts: Array[String]) -> void:
	if _is_dialogue_mode:
		return

	_is_dialogue_mode = true
	_dialogue_help_texts = help_texts
	_line_dialogue_help()

# 会話モードを継続する
func continue_dialogue(word: String) -> void:
	if not _is_dialogue_mode:
		return

	_dialogue_input_words.append(word)

	# コマンドを最後まで入力しきったら会話モードを終了する 
	if _dialogue_input_words.size() == _dialogue_help_texts.size():
		finish_dialogue()
	else:
		_line_dialogue_help()


# 会話モードを終了する + コマンドを実行する
func finish_dialogue() -> void:
	if not _is_dialogue_mode:
		return

	# コマンドを実行する
	_cli_commands.exec_command(_dialogue_input_words)

	_is_dialogue_mode = false
	_dialogue_help_texts = []
	_dialogue_input_words = []

# 会話ヘルプを表示する
func _line_dialogue_help() -> void:
	var _current_step = _dialogue_input_words.size()
	var _current_help_text = _dialogue_help_texts[_current_step]
	line_main(_current_help_text)


func _process_refresh_label() -> void:
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
	_cli_commands.exec_command(words)
