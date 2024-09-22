# 従業員関連のクラス
# CoreEmployeeBase.new() で生成する
class_name CoreEmployeeBase
extends Node


enum SpecRank { F, E, D, C, B, A, S, X }


# スペックランクのマスターデータ [ <from>, <to>, SpecRank ]
const RANK_DATA = [
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
var cost: int = 60 # 月単価

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

var _core: Core


func _init(screen_name: String) -> void:
	self.screen_name = screen_name

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
	for rank_data in RANK_DATA:
		if rank_data[0] <= spec and spec <= rank_data[1]:
			rank = rank_data[2]
	return rank

func get_rank_string(spec: int) -> String:
	var rank = get_rank(spec)
	return SpecRank.keys()[rank]


# 生産/加工 作業を開始する
func start_work(material_type: CoreMaterial.Type) -> void:
	pass
