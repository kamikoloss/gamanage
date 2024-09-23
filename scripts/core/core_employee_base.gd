# 従業員関連のクラス
# 個別の従業員は CoreEmployeeBase.new() で生成する
# TODO: タスクの最大数 (強化できてもいいかも)
class_name CoreEmployeeBase
extends Node


signal task_changed


enum SpecRank { F, E, D, C, B, A, S, X }
enum TaskType { MATERIAL }


# スペックランクのマスターデータ [ <from>, <to>, SpecRank ]
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


var screen_name: String = "" # 表示名
var cost: int = 0 # 月単価

# スペック (0-255)
var spec_mental: int = 100 # 精神力
var spec_communication: int = 100 # コミュ力
var spec_engineering: int = 100 # エンジニアリング力
var spec_art: int = 100 # アート力

# 性格 (MBTI): true の場合は前者である
var mbti_ei: bool = true # Extraversion (外向型) vs Intraversion (内向型)
var mbti_sn: bool = false # Sensing (感覚型) vs iNtuition (直感型)
var mbti_tf: bool = false # Thinking (思考型) vs Feeling (感情型)
var mbti_jp: bool = true # Judging (規範型) vs Perceiving (自由型)
var mbti_string: String = "":
	get:
		var ei = "E" if mbti_ei else "I"
		var sn = "S" if mbti_sn else "N"
		var tf = "T" if mbti_tf else "F"
		var jp = "J" if mbti_jp else "P"
		return ei + sn + tf + jp
var mbti_roll: String = "":
	get:
		return MBTI_ROLL_DATA[mbti_string]

# タスクリスト [ [ TaskType, <ResourceID> ], ... ]
var task_list: Array = []


var _core: Core

var _current_task: Array = [] # 現在進めているタスク (task_list のひとつ)
var _current_task_progress: float = 0.0 # 現在のタスクの進捗 (素材1個ごと)


func _init(screen_name: String) -> void:
	self.screen_name = screen_name


func _process(delta: float) -> void:
	_process_task(delta)


func init_core(core: Core) -> void:
	_core = core

func init_spec(mental: int, communication: int, engineering: int, art: int) -> void:
	self.spec_mental = mental
	self.spec_communication = communication
	self.spec_engineering = engineering
	self.spec_art = art

func init_mbti(ei: bool, sn: bool, tf: bool, jp: bool) -> void:
	self.mbti_ei = ei
	self.mbti_sn = sn
	self.mbti_tf = tf
	self.mbti_jp = jp


func get_rank(spec: int) -> SpecRank:
	var rank = SpecRank.F
	for data in SPEC_RANK_DATA:
		if data[0] <= spec and spec <= data[1]:
			rank = data[2]
	return rank

func get_rank_string(spec: int) -> String:
	var rank = get_rank(spec)
	return SpecRank.keys()[rank]


func add_task_material(material_type: CoreMaterial.Type) -> Array:
	var has_same_task = task_list.any(func(v): return v[0] == TaskType.MATERIAL and v[1] == material_type)
	if not has_same_task:
		task_list.append([TaskType.MATERIAL, material_type])
	_check_task()
	return task_list

func remove_task_material(material_type: CoreMaterial.Type) -> Array:
	task_list = task_list.filter(func(v): return not (v[0] == TaskType.MATERIAL and v[1] == material_type))
	_check_task()
	return task_list


# タスクリストの中から現在できるタスクを探す
func _check_task() -> void:
	# タスクが設定されていない場合: 終了する
	if task_list.is_empty():
		return
	# TODO: 会社資金が足りない場合は作業を止める

	var is_found_task = false
	for task in task_list:
		var material_type = task[1]
		var amount = _core.get_material_amount(material_type)
		var max_stack = CoreMaterial.MATERIAL_DATA[material_type]["max_stack"]

		# 最大数所持していない場合: このタスクを進める
		if amount < max_stack:
			var preview_task = _current_task
			_current_task = task
			if preview_task.is_empty() or (not preview_task.is_empty() and task[1] != preview_task[1]):
				task_changed.emit(self, _current_task)
			is_found_task = true
			break

	# できるタスクがない場合
	if not is_found_task and not _current_task.is_empty():
		_current_task = []
		task_changed.emit(self, _current_task)


func _process_task(delta: float) -> void:
	if _current_task.is_empty():
		return

	var material_type = _current_task[1]
	var material_out = CoreMaterial.MATERIAL_DATA[material_type]["out"]
	var added_progress = material_out * delta * _core.time_scale / 60 # time_scale によっては 2.0 以上になる
	_current_task_progress += added_progress

	if 1.0 < _current_task_progress:
		var new_amount = _core.get_material_amount(material_type) + int(floor(_current_task_progress))
		var max_stack = CoreMaterial.MATERIAL_DATA[material_type]["max_stack"]
		_core.material_amounts[material_type] = clampi(new_amount, 1, max_stack)
		_current_task_progress = 0.0
		_check_task()
