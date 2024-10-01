# ゲーム上の素材を管理するクラス
extends Node


# MaterialData のマスターデータ
const MATERIAL_DATA = {
	MaterialData.MaterialType.D2_1: { "name": "2D 素材 (1)", "max": 360 },
	MaterialData.MaterialType.D3_1: { "name": "3D 素材 (1)", "max": 360 },
	MaterialData.MaterialType.PROGRAM_1: { "name": "プログラム (1)", "max": 360 },
	MaterialData.MaterialType.ACTION_1: { "name": "アクションゲーム (1)", "max": 360, "goal": 120 },
	MaterialData.MaterialType.RPG_1: { "name": "RPG ゲーム (1)", "max": 360, "goal": 120 },
}


var _unlocked_materials: Dictionary = {} # アンロックされている素材のリスト { MaterialType: MaterialData }
var _material_amounts: Dictionary = {} # 素材の所持数 { MaterialType: <amount> }


func get_material(type: MaterialData.MaterialType) -> MaterialData:
	if _unlocked_materials.keys().has(type):
		return _unlocked_materials[type]
	else:
		return null

func get_materials() -> Array:
	return _unlocked_materials.values()


func get_material_amount(type: MaterialData.MaterialType) -> int:
	if _unlocked_materials.keys().has(type):
		return _material_amounts[type]
	else:
		return -1

func set_material_amount(type: MaterialData.MaterialType, amount: int) -> int:
	var material = get_material(type)
	_material_amounts[type] = clampi(amount, 0, material.max_amount)
	return get_material_amount(type)

func increment_amount(type: MaterialData.MaterialType, amount: int) -> int:
	set_material_amount(type, get_material_amount(type) + amount)
	return get_material_amount(type)


func unlock_material(type: MaterialData.MaterialType) -> void:
	var data = MATERIAL_DATA[type]

	var material = MaterialData.new()
	material.type = type
	if data.has("name"):
		material.screen_name = data["name"]
	if data.has("max"):
		material.max_amount = data["max"]
	if data.has("goal"):
		material.goal_base_amount = data["goal"]

	_unlocked_materials[type] = material
	_material_amounts[type] = 0
