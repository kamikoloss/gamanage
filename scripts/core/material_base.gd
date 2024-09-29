# 素材の情報を表現するクラス (1個とか1スタックではない)
# 新しい素材は MaterialBase.new() で生成する
class_name MaterialBase
extends Node


var type: MaterialManager.MaterialType # 素材の種別
var screen_name: String = "" # 素材の表示名
var max_amount: int = 0 # 最大いくつまで保持できるかの初期値
var goal_base: int = -1 # (ゲームの場合のみ) 完成度が 100% になる基準


# レシピ
var input = [] # [ [ MaterialType, 消費量], ... ]
var output = 60 # 1分あたりの生産量
