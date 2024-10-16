# 従業員を表現するクラス
# TODO: タスクの最大数 (強化できてもいいかも)
class_name EmployeeBase
extends Object


# 進めるタスクが変わったとき (やることがなくなったときも含む)
signal task_changed # (EmployeeBase, MaterialData)


enum SpecRank { F, E, D, C, B, A, S, X }


# スペックランクの範囲データ [ <from>, <to>, SpecRank ]
const SPEC_RANK_DATA = [
	[0, 31, SpecRank.F],
	[32, 63, SpecRank.E],
	[64, 95, SpecRank.D],
	[96, 127, SpecRank.C],
	[128, 159, SpecRank.B],
	[160, 191, SpecRank.A],
	[192, 223, SpecRank.S],
	[224, 255, SpecRank.X],
]

# MBTI の性格タイプ
# ref. https://www.16personalities.com/ja/%E6%80%A7%E6%A0%BC%E3%82%BF%E3%82%A4%E3%83%97
const MBTI_ROLL_DATA = {
	"INTJ": "建築家", "INTP": "論理学者", "ENTJ": "指揮官", "ENTP": "討論者",
	"INFJ": "提唱者", "INFP": "仲介者", "ENFJ": "主人公", "ENFP": "運動家",
	"ISTJ": "管理者", "ISFJ": "擁護者", "ESTJ": "幹部", "ESFJ": "領事",
	"ISTP": "巨匠", "ISFP": "冒険家", "ESTP": "起業家", "ESFP": "エンターテイナー",
}


# ID 雇った順に1ずつ増えていく
var id: int = 0
# 表示名
var screen_name: String = ""
# 月単価
var cost: int = 0

# [ 精神力, コミュ力, エンジニアリング力, アート力 ]
var specs: Array[int]:
	get:
		return [_spec_mental, _spec_communication, _spec_engineering, _spec_art]
var specs_rank: Array:
	get:
		return [
			_get_spec_rank(_spec_mental),
			_get_spec_rank(_spec_communication),
			_get_spec_rank(_spec_engineering),
			_get_spec_rank(_spec_art),
		]
var specs_rank_string: Array[String]:
	get:
		return [
			_get_spec_rank_string(_spec_mental),
			_get_spec_rank_string(_spec_communication),
			_get_spec_rank_string(_spec_engineering),
			_get_spec_rank_string(_spec_art),
		]

var mbti_string: String:
	get:
		var ei = "E" if _mbti_ei else "I"
		var sn = "S" if _mbti_sn else "N"
		var tf = "T" if _mbti_tf else "F"
		var jp = "J" if _mbti_jp else "P"
		return ei + sn + tf + jp
var mbti_roll: String:
	get:
		return MBTI_ROLL_DATA[mbti_string]

var progress_percent: int:
	get:
		return int(ceil(_current_task_progress * 100))
var has_task: bool:
	get:
		return not _task_list.is_empty()
var is_working: bool:
	get:
		return _current_task != null


# ステータス (0-255)
var _spec_mental: int = 100 # 精神力
var _spec_communication: int = 100 # コミュ力
var _spec_engineering: int = 100 # エンジニアリング力
var _spec_art: int = 100 # アート力

# 性格 (MBTI): true の場合は前者である
var _mbti_ei: bool = true # Extraversion (外向型) vs Intraversion (内向型)
var _mbti_sn: bool = false # Sensing (感覚型) vs iNtuition (直感型)
var _mbti_tf: bool = false # Thinking (思考型) vs Feeling (感情型)
var _mbti_jp: bool = true # Judging (規範型) vs Perceiving (自由型)

# タスク関連
# TODO: MaterialData 以外のタスク
var _last_worked_time: float = 0.0 # 最後に働いた時間 (Unixtime)
var _task_list: Array = [] # タスクリスト
var _task_list_max_length = 1 # タスクリストの最大の長さ
var _current_task: MaterialData = null # 現在進めているタスク
var _current_task_progress: float = 0.0 # 現在のタスクの進捗 (生産素材1セット = 1.0)


func _init(screen_name: String) -> void:
	self.screen_name = screen_name


func set_spec(mental: int, communication: int, engineering: int, art: int) -> void:
	_spec_mental = mental
	_spec_communication = communication
	_spec_engineering = engineering
	_spec_art = art

func set_mbti(ei: bool, sn: bool, tf: bool, jp: bool) -> void:
	_mbti_ei = ei
	_mbti_sn = sn
	_mbti_tf = tf
	_mbti_jp = jp


func get_tasks() -> Array:
	return _task_list

func add_task(material: MaterialData) -> Array:
	if not _task_list.any(func(v): return v.type == material.type):
		_task_list.append(material)
		if _task_list_max_length < _task_list.size():
			_task_list.pop_front()
	_check_task()
	return _task_list

func remove_task(material: MaterialData) -> Array:
	_task_list = _task_list.filter(func(v): return v.type != material.type)
	_current_task_progress = 0.0
	_check_task()
	return _task_list


# 割り当てられているタスクを進める
# 一定時間ごとに呼ばれる前提
func work() -> void:
	var delta: float = Time.get_unix_time_from_system() - _last_worked_time
	_last_worked_time = Time.get_unix_time_from_system()

	if _current_task == null:
		return

	# NOTE: progress は time_scale と work() を呼ぶ頻度によっては 2.0 を上回ることがある
	var output_set: int = _current_task.output / _current_task.unit # 1分あたり何セット生産するか
	var progress: float = output_set * delta * GameManager.time_scale / 60 # 1セットの進捗がどれだけ進んだか
	_current_task_progress += progress

	# 進捗が 1.0 を超えている場合 = 1セット以上生産できた場合
	if 1.0 < _current_task_progress:
		var progress_int: float = floor(_current_task_progress) # 現在の進捗の整数部分
		# 生産素材を増やす
		var increment: int = _current_task.unit * int(progress_int) # 何個増えたか
		MaterialManager.increase_amount(_current_task.type, increment)
		# 消費素材を減らす
		# 消費素材が設定されていない場合 (空配列) は for が回らないので何も減らない
		for input in _current_task.input:
			var input_material_type: MaterialData.MaterialType = input[0]
			var input_amount: int = input[1]
			var decrement: int = (input_amount / output_set) * int(progress_int) # 何個減ったか
			MaterialManager.decrease_amount(input_material_type, decrement)
		# 進捗を減らす
		_current_task_progress -= progress_int
		# タスクを確認する
		_check_task()


func _get_spec_rank(spec: int) -> SpecRank:
	var spec_rank = SpecRank.F
	for data in SPEC_RANK_DATA:
		if data[0] <= spec and spec <= data[1]:
			spec_rank = data[2]
			break
	return spec_rank

func _get_spec_rank_string(spec: int) -> String:
	var spec_rank = _get_spec_rank(spec)
	return SpecRank.keys()[spec_rank]


# タスクリストの中から現在できるタスクを探す
# タスクを 追加/削除 されたとき, 素材を作り終えたとき に呼ぶ
func _check_task() -> void:
	# TODO: 会社資金が足りない場合は作業を止める

	var is_found_task = false
	for task_material: MaterialData in _task_list:
		# 生産素材を最大数所持している場合: 次のタスクを見る
		var amount = MaterialManager.get_material_amount(task_material.type)
		if task_material.max_amount <= amount:
			continue
		# 消費素材が足りない場合: 次のタスクを見る
		# 消費素材が設定されていない場合 (空配列) は for が回らないので true にならない
		var has_no_input = false
		for input in task_material.input:
			var input_material_type: MaterialData.MaterialType = input[0]
			var input_amount: int = input[1]
			var input_current_amount = MaterialManager.get_material_amount(input_material_type) # 消費素材の現在の量
			var output_set: int = task_material.output / task_material.unit # 1分あたり何セット生産するか
			var required_amount = int(ceil(input_amount / output_set)) # 1セット生産するのに何個必要か
			if input_current_amount < required_amount:
				has_no_input = true
		if has_no_input:
			continue

		# やることが見つかった場合
		is_found_task = true
		var preview_task = _current_task
		_current_task = task_material
		_current_task_progress = 0.0
		# 見つかったタスクが前と違う場合: signal を発火する
		if preview_task == null or preview_task.type != _current_task.type:
			task_changed.emit(self, _current_task)
		# タスクを探すのをやめる
		break

	# できるタスクがなくなった場合: signal を発火する
	if not is_found_task and _current_task != null:
		_current_task = null
		_current_task_progress = 0.0
		task_changed.emit(self, _current_task)
