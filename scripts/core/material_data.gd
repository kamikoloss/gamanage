# 素材のマスターデータを記述するクラス
class_name MaterialData
extends Node


# 素材の種別
enum Type {
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


# 素材のメタデータ
const DATA = {
	Type.D2_1: { "name": "2D 素材 (1)", "max": 360 },
	Type.D3_1: { "name": "3D 素材 (1)", "max": 360 },
	Type.PROGRAM_1: { "name": "プログラム (1)", "max": 360 },
	Type.ACTION_1: { "name": "アクションゲーム (1)", "max": 360, "goal": 120 },
	Type.RPG_1: { "name": "RPG ゲーム (1)", "max": 360, "goal": 120 },
}

# 素材の制作レシピ 量は1分あたり
# [ [[Type, 必要量], ...], [[Type, 生産量], ...] ]
const RECIPE = [
	[
		[[Type.WORK]],
		[[Type.D2_1, 60]],
	],
	[
		[[Type.WORK]],
		[[Type.D3_1, 60]],
	],
	[
		[[Type.WORK]],
		[[Type.PROGRAM_1, 60]],
	],
	[
		[[Type.D2_1, 60], [Type.PROGRAM_1, 60]],
		[[Type.ACTION_1, 60]],
	],
	[
		[[Type.D2_1, 60], [Type.PROGRAM_1, 120]],
		[[Type.RPG_1, 60]],
	],
]
