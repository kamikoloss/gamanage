# 従業員関連のクラス
# CoreEmployeeBase.new() で生成する
class_name CoreEmployeeBase
extends Node


var screen_name: String = "従業員" # 表示名
var cost: int = 60 # 月単価

# スペック
var spec_mental = 32 # 精神力
var spec_communication = 32 # コミュ力
var spec_engineering = 32 # エンジニアリング力
var spec_art = 32 # アート力

# 性格 (MBTI): true の場合は前者である
var mbti_ei = true # Extraversion (外向型) vs Intraversion (内向型)
var mbti_sn = true # Sensing (感覚型) vs iNtuition (直感型)
var mbti_tf = true # Thinking (思考型) vs Feeling (感情型)
var mbti_jp = true # Judging (規範型) vs Perceiving (自由型)


func _init(screen_name: String) -> void:
	self.screen_name = screen_name

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
