# 素材関連のクラス
class_name CoreMaterial
extends Node


# 素材の種別
enum Type {
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
	RPG_1, RPG_2,
	ACTION_1, ACTION_2,
	NOVEL_1, NOVEL_2,
}


# 素材のマスターデータ
# name: 表示名
# in: (加工品の場合のみ) 必要材料 [ [ CoreMaterial.Type, <必要量> ], ... ]
# out: 生産ペース (/分)
# max: 最大いくつまで貯めておけるかの初期値
# goal: (ゲームの場合のみ) 完成度が 100% になる基準
const MATERIAL_DATA = {
	Type.D2_1: {
		"name": "2D 素材 (1)",
		"out": 60,
		"max": 360,
	},
	Type.D3_1: {
		"name": "3D 素材 (1)",
		"out": 60,
		"max": 360,
	},
	Type.PROGRAM_1: {
		"name": "プログラム (1)",
		"out": 60,
		"max": 360,
	},
	Type.RPG_1: {
		"name": "RPG ゲーム (1)",
		"in": [[Type.D2_1, 60], [Type.PROGRAM_1, 60]],
		"out": 60,
		"max": 360,
		"goal": 120,
	},
}
