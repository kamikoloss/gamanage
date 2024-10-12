# ゲームのパッケージと販売を管理するクラス
extends Node


var _saling_games: Array[SaleBase] = [] # 販売中のゲームのリスト
var _saled_games: Array[SaleBase] = [] # 販売終了したゲームのリスト


# ゲームを販売開始する
func deploy_game(material_type: MaterialData.MaterialType, amount: int) -> void:
	pass
