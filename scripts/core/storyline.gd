# ストーリーの流れを表現するクラス
class_name Storyline
extends Node


func _ready() -> void:
	# 初期アンロック
	MaterialManager.unlock_material(MaterialData.MaterialType.D2_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.D3_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.PROGRAM_1)
	MaterialManager.unlock_material(MaterialData.MaterialType.RPG_1)


func _process(delta: float) -> void:
	pass
