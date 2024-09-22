# 素材関連のクラス
class_name CoreMaterial
extends Node


# 素材の種別
enum Type {
	# 素材
	#PLAN_1,
	#SPEC_1,
	D2_1, # 2D
	D3_1, # 3D
	#MOTION_1,
	#EFFECT_1,
	#UI_1,
	#SE_1,
	#BGM_1,
	#VOICE_1,
	#MUSIC_1,
	LOGIC_1,
	#TEXT_1, TEXT_2,
	#SERVER,
	#CLIENT,
	# ゲーム
	RPG_1, #RPG_2,
	#ACTION_1, ACTION_2,
	#NOVEL_1, NOVEL_2,
}


const MATERIAL_DATA = {
	Type.D2_1: {
		"name": "2D 素材 (1)",
		"out": 60,
	},
	Type.D3_1: {
		"name": "3D 素材 (1)",
		"out": 60,
	},
	Type.LOGIC_1: {
		"name": "ロジック (1)",
		"out": 60,
	},
	Type.RPG_1: {
		"name": "RPG ゲーム (1)",
		"in": [[Type.D2_1, 60], [Type.LOGIC_1, 60]],
		"out": 30,
		"goal": 120,
	},
}
