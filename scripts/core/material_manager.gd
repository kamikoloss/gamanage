# ゲーム上の素材を管理するクラス
extends Node


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


# 素材のメタデータ
const MATERIAL_DATA = {
	MaterialType.D2_1: { "name": "2D 素材 (1)", "max": 360 },
	MaterialType.D3_1: { "name": "3D 素材 (1)", "max": 360 },
	MaterialType.PROGRAM_1: { "name": "プログラム (1)", "max": 360 },
	MaterialType.ACTION_1: { "name": "アクションゲーム (1)", "max": 360, "goal": 120 },
	MaterialType.RPG_1: { "name": "RPG ゲーム (1)", "max": 360, "goal": 120 },
}


# アンロックされている素材のリスト
# { MaterialType: MaterialBase }
var _unlocked_materials: Dictionary = {}


# 素材の所持数
# { MaterialType: <amount> }
# TODO: ストレージ概念
# TODO: スタック概念
var _material_amounts: Dictionary = {}


func _ready() -> void:
	# 初期アンロック
	unlock_material(MaterialType.D2_1)
	unlock_material(MaterialType.D3_1)
	unlock_material(MaterialType.PROGRAM_1)
	unlock_material(MaterialType.RPG_1)


func get_material_data(type: MaterialType) -> MaterialBase:
	return _unlocked_materials[type]


func get_material_amount(type: MaterialType) -> int:
	if _material_amounts.keys().has(type):
		return _material_amounts[type]
	else:
		return -1

func set_material_amount(type: MaterialType, amount: int) -> int:
	var material = get_material_amount(type)
	_material_amounts[type] = clampi(amount, 0, material.max_amount)
	return get_material_amount(type)

func increment_amount(type: MaterialType, amount: int) -> int:
	set_material_amount(type, get_material_amount(type) + amount)
	return get_material_amount(type)


func unlock_material(type: MaterialType) -> void:
	# 素材アンロック
	var data = MATERIAL_DATA[type]

	var material = MaterialBase.new()
	if data.has("name"):
		material.screen_name = data["name"]
	if data.has("max"):
		material.max_amount = data["has"]
	if data.has("goal"):
		material.goal_amount_base = data["goal"]

	_unlocked_materials[type] = material
	_material_amounts[type] = 0
