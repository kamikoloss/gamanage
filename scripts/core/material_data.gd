# 素材情報を表現するクラス (1個とか1スタックではない)
class_name MaterialData
extends Object


# 素材の種別
enum MaterialType {
	WORK,
	# 素材
	PLAN_1,
	SPEC_1,
	D2_1, # 2D
	D3_1, # 3D
	MOTION_1,
	EFFECT_1,
	UI_1,
	SE_1,
	BGM_1,
	VOICE_1,
	MUSIC_1,
	PROGRAM_1,
	TEXT_1, TEXT_2,
	SERVER,
	CLIENT,
	# ゲーム
	ACTION_1, ACTION_2,
	RPG_1, RPG_2,
	NOVEL_1, NOVEL_2,
}


# 素材の種別
# ID と表記されることもある
var type: MaterialType
# 生産素材をこれと同じ扱いにする (代替レシピ用)
var alias_type: MaterialType
# 素材の表示名
var screen_name: String = ""
# 最大いくつまで保持できるかの初期値
var max_amount: int = 0
# (ゲームの場合のみ) 完成度が 100% になる基準
var goal_base_amount: int = -1
# [ [ MaterialType, <1分あたりの消費量> ], ... ]
# 労働力によって生産される場合は空配列とする
var input = []
# 1分あたりの生産量
var output: int = 0
# 1セットあたりの生産量
# 消費量より生産量が多いときに設定する
var unit: int = 1
