# 従業員を表現するクラス
# TODO: タスクの最大数 (強化できてもいいかも)
class_name EmployeeBase
extends Object


# 進めるタスクが変わったとき (やることがなくなったときも含む)
signal task_changed


enum SpecRank { F, E, D, C, B, A, S, X }
enum TaskType { MATERIAL }


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


var id: int = 0
var screen_name: String = ""
var cost: int = 0 # 月単価

# [ 精神力, コミュ力, エンジニアリング力, アート力 ]
var specs: Array[int]:
	get:
		return [_spec_mental, _spec_communication, _spec_engineering, _spec_art]
var specs_rank: Array[SpecRank]:
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
# TODO: 生産 (MaterialData) 以外のタスク
var _last_worked_time: float = 0.0 # 最後に働いた時間 (Unixtime)
var _task_list: Array[MaterialData] = [] # タスクリスト
var _task_list_max_length = 3 # タスクリストの最大の長さ
var _current_task: MaterialData = null # 現在進めているタスク
var _current_task_progress: float = 0.0 # 現在のタスクの進捗 (生産素材1個 = 1.0)


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
	_check_task()
	return _task_list

func remove_task(material: MaterialData) -> Array:
	_task_list = _task_list.filter(func(v): return v.type != material.type)
	_check_task()
	return _task_list


# 割り当てられているタスクを進める
# 一定時間ごとに呼ばれる前提
func work() -> void:
	var delta = Time.get_unix_time_from_system() - _last_worked_time
	_last_worked_time = Time.get_unix_time_from_system()

	if _current_task == null:
		return

	# NOTE: progress は time_scale によっては 2.0 を上回ることがある
	var progress = _current_task.output * delta * GameManager.time_scale / 60
	_current_task_progress += progress

	# 進捗が 1.0 を超えている場合
	if 1.0 < _current_task_progress:
		MaterialManager.increment_amount(_current_task.type, int(floor(_current_task_progress)))
		_current_task_progress = 0.0
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
func _check_task() -> void:
	# タスクが設定されていない場合: 終了する
	if _task_list.is_empty():
		return
	# TODO: 会社資金が足りない場合は作業を止める

	var is_found_task = false
	for material: MaterialData in _task_list:
		# 最大数所持していない場合: このタスクを進める
		var amount = MaterialManager.get_material_amount(material.type)
		if amount < material.max_amount:
			var preview_task = _current_task
			_current_task = material
			is_found_task = true
			if preview_task == null or preview_task.type != _current_task.type:
				task_changed.emit(self, _current_task)
			break

	# できるタスクが見つからなかった場合 かつ 何かタスクを進めていた場合: signal を発火する
	# null から null への以降を除く
	if not is_found_task and _current_task != null:
		_current_task = null
		task_changed.emit(self, _current_task)
