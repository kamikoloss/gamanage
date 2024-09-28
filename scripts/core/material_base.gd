# 素材を表現するクラス
# 新しい素材は MaterialBase.new() で生成する
class_name MaterialBase
extends Node


var type: MaterialData.Type = MaterialData.Type.WORK
var screen_name: String = ""
var max_amount: int = 0 # 最大いくつまで保持できるかの初期値
var goal_amount_base: int = -1 # (ゲームの場合のみ) 完成度が 100% になる基準


func _init(screen_name: String):
	self.screen_name = screen_name
