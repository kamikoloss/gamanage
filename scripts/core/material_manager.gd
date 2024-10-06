# ゲーム上の素材を管理するクラス
extends Node

# 素材がアンロックされたとき
signal material_unlocked # (MaterialData)
# 素材の数が増減したとき
signal material_amount_changed # (MaterialData, <new amount>)


# MaterialData のマスターデータ
const MATERIAL_DATA = {
	MaterialData.MaterialType.D2_1: {
		"name": "2D 素材 (1)", "max": 360, "output": 60,
	},
	MaterialData.MaterialType.D3_1: {
		"name": "3D 素材 (1)", "max": 360, "output": 60,
	},
	MaterialData.MaterialType.PROGRAM_1: {
		"name": "プログラム (1)", "max": 360, "output": 60,
	},
	MaterialData.MaterialType.ACTION_1: {
		"name": "アクションゲーム (1)", "max": 360, "output": 30,
		"input": [
			[MaterialData.MaterialType.D2_1, 60],
			[MaterialData.MaterialType.PROGRAM_1, 60]
		],
		"goal": 120,
	},
	MaterialData.MaterialType.RPG_1: {
		"name": "RPG ゲーム (1)", "max": 360, "output": 30,
		"input": [
			[MaterialData.MaterialType.D2_1, 60],
			[MaterialData.MaterialType.PROGRAM_1, 120]
		],
		"goal": 120,
	},
}


var _unlocked_materials: Dictionary = {} # アンロックされている素材のリスト { MaterialType: MaterialData }
var _material_amounts: Dictionary = {} # 素材の所持数 { MaterialType: <amount> }


func get_material(material_type: MaterialData.MaterialType) -> MaterialData:
	if _unlocked_materials.keys().has(material_type):
		return _unlocked_materials[material_type]
	else:
		return null

func get_materials() -> Array:
	return _unlocked_materials.values()


func get_material_amount(material_type: MaterialData.MaterialType) -> int:
	if _unlocked_materials.keys().has(material_type):
		return _material_amounts[material_type]
	else:
		return -1

func set_material_amount(material_type: MaterialData.MaterialType, amount: int) -> int:
	var material = get_material(material_type)
	_material_amounts[material_type] = clampi(amount, 0, material.max_amount)
	return get_material_amount(material_type)

func increase_amount(material_type: MaterialData.MaterialType, amount: int) -> int:
	set_material_amount(material_type, get_material_amount(material_type) + amount)
	return get_material_amount(material_type)

func decrease_amount(material_type: MaterialData.MaterialType, amount: int) -> int:
	set_material_amount(material_type, get_material_amount(material_type) - amount)
	return get_material_amount(material_type)


func unlock_material(material_type: MaterialData.MaterialType) -> void:
	var data = MATERIAL_DATA[material_type]

	var material = MaterialData.new()
	material.type = material_type
	if data.has("name"):
		material.screen_name = data["name"]
	if data.has("max"):
		material.max_amount = data["max"]
	if data.has("output"):
		material.output = data["output"]
	if data.has("unit"):
		material.unit = data["unit"]
	if data.has("input"):
		material.input = data["input"]
	if data.has("goal"):
		material.goal_base_amount = data["goal"]

	_unlocked_materials[material_type] = material
	_material_amounts[material_type] = 0
	
	material_unlocked.emit(material)
