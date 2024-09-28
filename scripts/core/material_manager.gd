# ゲーム上の素材を管理するクラス
extends Node


# アンロックされている素材のリスト
#  { CoreMaterial.Type: MaterialBase }
var _unlocked_materials: Dictionary = {}
# 素材の所持数
# { CoreMaterial.Type: <amount> }
var _material_amounts: Dictionary = {}


func _ready() -> void:
	# 初期アンロック
	unlock_material(MaterialData.Type.D2_1)
	unlock_material(MaterialData.Type.D3_1)
	unlock_material(MaterialData.Type.PROGRAM_1)
	unlock_material(MaterialData.Type.RPG_1)


func get_material_data(type: MaterialData.Type) -> MaterialBase:
	return _unlocked_materials[type]


func get_material_amount(type: MaterialData.Type) -> int:
	if _material_amounts.keys().has(type):
		return _material_amounts[type]
	else:
		return -1

func set_material_amount(type: MaterialData.Type, amount: int) -> int:
	var material = get_material_amount(type)
	_material_amounts[type] = clampi(amount, 0, material.max_amount)
	return get_material_amount(type)

func increment_amount(type: MaterialData.Type, amount: int) -> int:
	set_material_amount(type, get_material_amount(type) + amount)
	return get_material_amount(type)


func unlock_material(type: MaterialData.Type) -> void:
	var data = MaterialData.DATA[type]
	var material = MaterialBase.new(data["name"])
	if data.has("max"):
		material.max_amount = data["has"]
	if data.has("goal"):
		material.goal_amount_base = data["goal"]

	_unlocked_materials[type] = material
	_material_amounts[type] = 0
