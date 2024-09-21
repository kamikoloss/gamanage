extends Node


const FIRST_LEVEL_COMMANDS = [
	"help",
	"quit",
]


@export var _line_edit: LineEdit
@export var _label_1: RichTextLabel
@export var _label_2: RichTextLabel
@export var _label_3: RichTextLabel
@export var _label_4: RichTextLabel

var _version = "v0.0.0"
var _current_commands = []
var _label_3_lines = []

var _help_descriptions = {
	"help": "コマンド一覧を表示します",
	"quit": "ゲームを終了します",
}


func _ready() -> void:
	_line_edit.grab_focus()
	_append_line("----------------------------------------------------------------")
	_append_line("GAMANAGE CLI %s" % [_version])
	_append_line("\"help\" と打つことでコマンド一覧が表示されます")
	_append_line("----------------------------------------------------------------")


func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_ENTER:
				_append_line("$ " + _line_edit.text) # 打ったコマンド自体を表示する
				_parse_command(_line_edit.text)
				_line_edit.text = ""


func _append_line(line: String, label_id: int = 3) -> void:
	match label_id:
		1:
			pass
		2:
			pass
		3:
			_label_3_lines.append(line)
			_label_3.text = "\n".join(_label_3_lines)
			_label_3.scroll_to_line(9999)
		4:
			pass


func _parse_command(line: String) -> void:
	# コマンドを whitespace で分割する
	# whitespace 自体は第2引数によって除外される
	var words = Array(line.split(" ", false))

	# コマンドを何も入力せずに Enter を押したとき: 何もせずに終了する (単なる改行送りになる)
	if words.size() == 0:
		return

	# コマンドリストにないコマンドが入力されたとき: エラーを表示して終了する
	if not words[0] in FIRST_LEVEL_COMMANDS:
		_append_line("[color=red]%s: invalid command![/color]" % line)
		return

	match words[0]:
		"help":
			var help_text_list = FIRST_LEVEL_COMMANDS.map(func(v): return v + "\t\t" + _help_descriptions[v])
			var help_text = "\n".join(help_text_list)
			_append_line(help_text)
		"quit":
			get_tree().quit()
